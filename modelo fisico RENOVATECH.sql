
USE master;


GO
IF DB_ID(N'RenovaTech') IS NULL
    CREATE DATABASE RenovaTech COLLATE Modern_Spanish_CI_AS;


GO
USE RenovaTech;


GO
/* ==========================================================================
   1. TABLAS
   ========================================================================== */
-- Roles del sistema: Administrador y Comprador
CREATE TABLE dbo.Rol (
    IdRol     TINYINT      NOT NULL,
    NombreRol VARCHAR (20) NOT NULL,
    CONSTRAINT PK_Rol PRIMARY KEY (IdRol),
    CONSTRAINT UQ_Rol_Nombre UNIQUE (NombreRol)
);


GO
-- Usuarios que inician sesión (la contraseña se guarda como hash SHA-256)
CREATE TABLE dbo.Usuario (
    IdUsuario      INT            IDENTITY (1, 1) NOT NULL,
    NombreUsuario  VARCHAR (20)   NOT NULL,
    ClaveHash      VARBINARY (32) NOT NULL,
    NombreCompleto NVARCHAR (100) NOT NULL,
    Correo         NVARCHAR (120) NULL,
    IdRol          TINYINT        NOT NULL,
    FechaRegistro  DATETIME2 (0)  CONSTRAINT DF_Usuario_Fecha DEFAULT (SYSDATETIME()) NOT NULL,
    Activo         BIT            CONSTRAINT DF_Usuario_Activo DEFAULT (1) NOT NULL,
    CONSTRAINT PK_Usuario PRIMARY KEY (IdUsuario),
    CONSTRAINT UQ_Usuario_NombreUsuario UNIQUE (NombreUsuario),
    CONSTRAINT FK_Usuario_Rol FOREIGN KEY (IdRol) REFERENCES dbo.Rol (IdRol),
    CONSTRAINT CK_Usuario_NombreUsuario CHECK (LEN(NombreUsuario) >= 4
                                               AND NombreUsuario COLLATE Latin1_General_BIN NOT LIKE '%[^A-Za-z0-9_.]%'),
    CONSTRAINT CK_Usuario_Correo CHECK (Correo IS NULL
                                        OR Correo LIKE '%_@_%._%')
);


GO
-- El correo no puede repetirse, pero varios usuarios pueden no tener correo
CREATE UNIQUE INDEX UX_Usuario_Correo
    ON dbo.Usuario(Correo) WHERE Correo IS NOT NULL;


GO
-- Categorías de producto (Computadoras, Accesorios, ...)
CREATE TABLE dbo.Categoria (
    IdCategoria     INT           IDENTITY (1, 1) NOT NULL,
    NombreCategoria NVARCHAR (50) NOT NULL,
    CONSTRAINT PK_Categoria PRIMARY KEY (IdCategoria),
    CONSTRAINT UQ_Categoria_Nombre UNIQUE (NombreCategoria)
);


GO
-- Catálogo de productos. La baja es lógica (Activo = 0) para no perder el historial de pedidos.
CREATE TABLE dbo.Producto (
    CodigoProducto VARCHAR (10)    NOT NULL,
    Nombre         NVARCHAR (100)  NOT NULL,
    IdCategoria    INT             NOT NULL,
    Precio         DECIMAL (10, 2) NOT NULL,
    Stock          INT             CONSTRAINT DF_Producto_Stock DEFAULT (0) NOT NULL,
    Estado         AS              CAST (CASE WHEN Stock > 0 THEN 'Disponible' ELSE 'Agotado' END AS VARCHAR (10)) PERSISTED,
    RutaImagen     NVARCHAR (260)  CONSTRAINT DF_Producto_Imagen DEFAULT (N'img/productos/generico.svg') NOT NULL,
    Activo         BIT             CONSTRAINT DF_Producto_Activo DEFAULT (1) NOT NULL,
    FechaRegistro  DATETIME2 (0)   CONSTRAINT DF_Producto_Fecha DEFAULT (SYSDATETIME()) NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (CodigoProducto),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (IdCategoria) REFERENCES dbo.Categoria (IdCategoria),
    CONSTRAINT CK_Producto_Codigo CHECK (LEN (
                                             LTRIM (
                                                 RTRIM (CodigoProducto)
                                             )
                                         ) > 0),
    CONSTRAINT CK_Producto_Precio CHECK (Precio > 0),
    CONSTRAINT CK_Producto_Stock CHECK (Stock >= 0)
);


GO
CREATE INDEX IX_Producto_Categoria
    ON dbo.Producto(IdCategoria);

CREATE INDEX IX_Producto_Nombre
    ON dbo.Producto(Nombre);


GO
-- Métodos de pago disponibles al finalizar la compra
CREATE TABLE dbo.MetodoPago (
    IdMetodoPago TINYINT       NOT NULL,
    NombreMetodo NVARCHAR (50) NOT NULL,
    CONSTRAINT PK_MetodoPago PRIMARY KEY (IdMetodoPago),
    CONSTRAINT UQ_MetodoPago_Nombre UNIQUE (NombreMetodo)
);


GO
-- Cabecera de cada compra (pedido) realizada por un comprador
CREATE TABLE dbo.Pedido (
    IdPedido     INT             IDENTITY (1, 1) NOT NULL,
    NumeroPedido AS              CAST ('PED-' + CASE WHEN IdPedido < 10000 THEN RIGHT('0000' + CAST (IdPedido AS VARCHAR (10)), 4) ELSE CAST (IdPedido AS VARCHAR (10)) END AS VARCHAR (14)) PERSISTED,
    IdUsuario    INT             NOT NULL,
    IdMetodoPago TINYINT         NOT NULL,
    FechaPedido  DATETIME2 (0)   CONSTRAINT DF_Pedido_Fecha DEFAULT (SYSDATETIME()) NOT NULL,
    Total        DECIMAL (12, 2) CONSTRAINT DF_Pedido_Total DEFAULT (0) NOT NULL,
    CONSTRAINT PK_Pedido PRIMARY KEY (IdPedido),
    CONSTRAINT FK_Pedido_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuario (IdUsuario),
    CONSTRAINT FK_Pedido_MetodoPago FOREIGN KEY (IdMetodoPago) REFERENCES dbo.MetodoPago (IdMetodoPago),
    CONSTRAINT CK_Pedido_Total CHECK (Total >= 0)
);


GO
CREATE INDEX IX_Pedido_Usuario_Fecha
    ON dbo.Pedido(IdUsuario, FechaPedido DESC);


GO
-- Líneas de cada pedido. PrecioUnitario guarda el precio del momento de la compra.
CREATE TABLE dbo.DetallePedido (
    IdPedido       INT             NOT NULL,
    CodigoProducto VARCHAR (10)    NOT NULL,
    Cantidad       INT             NOT NULL,
    PrecioUnitario DECIMAL (10, 2) NOT NULL,
    Subtotal       AS              CAST (Cantidad * PrecioUnitario AS DECIMAL (12, 2)) PERSISTED,
    CONSTRAINT PK_DetallePedido PRIMARY KEY (IdPedido, CodigoProducto),
    CONSTRAINT FK_DetallePedido_Pedido FOREIGN KEY (IdPedido) REFERENCES dbo.Pedido (IdPedido) ON DELETE CASCADE,
    CONSTRAINT FK_DetallePedido_Producto FOREIGN KEY (CodigoProducto) REFERENCES dbo.Producto (CodigoProducto),
    CONSTRAINT CK_DetallePedido_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_DetallePedido_Precio CHECK (PrecioUnitario > 0)
);


GO
CREATE INDEX IX_DetallePedido_Producto
    ON dbo.DetallePedido(CodigoProducto);


GO
-- Carrito de cada comprador: un producto aparece una sola vez por usuario
CREATE TABLE dbo.ItemCarrito (
    IdUsuario      INT           NOT NULL,
    CodigoProducto VARCHAR (10)  NOT NULL,
    Cantidad       INT           NOT NULL,
    FechaAgregado  DATETIME2 (0) CONSTRAINT DF_ItemCarrito_Fecha DEFAULT (SYSDATETIME()) NOT NULL,
    CONSTRAINT PK_ItemCarrito PRIMARY KEY (IdUsuario, CodigoProducto),
    CONSTRAINT FK_ItemCarrito_Usuario FOREIGN KEY (IdUsuario) REFERENCES dbo.Usuario (IdUsuario) ON DELETE CASCADE,
    CONSTRAINT FK_ItemCarrito_Producto FOREIGN KEY (CodigoProducto) REFERENCES dbo.Producto (CodigoProducto),
    CONSTRAINT CK_ItemCarrito_Cantidad CHECK (Cantidad > 0)
);


GO
/* ==========================================================================
   2. DATOS INICIALES (los mismos de la aplicación web)
   ========================================================================== */
INSERT  INTO dbo.Rol (
    IdRol,
    NombreRol
)
VALUES               (1, 'Administrador'),
                     (2, 'Comprador');

INSERT  INTO dbo.MetodoPago (
    IdMetodoPago,
    NombreMetodo
)
VALUES                      (1, N'Efectivo contra entrega'),
                            (2, N'Tarjeta de crédito o débito'),
                            (3, N'Yape / Plin'),
                            (4, N'Transferencia bancaria');

-- Cuentas de demostración (contraseñas: admin123 y comprador123).
-- El hash se calcula sobre texto Unicode (NVARCHAR); usa siempre la misma convención.
INSERT  INTO dbo.Usuario (
    NombreUsuario,
    ClaveHash,
    NombreCompleto,
    Correo,
    IdRol
)
VALUES                   ('admin', HASHBYTES('SHA2_256', N'admin123'), N'JORDAN VERA', NULL, 1),
                         ('comprador', HASHBYTES('SHA2_256', N'comprador123'), N'MARÍA LÓPEZ', NULL, 2);

INSERT  INTO dbo.Categoria (
    NombreCategoria
)
VALUES                     (N'Accesorios'),
                           (N'Computadoras'),
                           (N'Impresoras'),
                           (N'Monitores'),
                           (N'Redes');

-- 20 productos: 17 disponibles y 3 agotados (P003, P004 y P005)
INSERT INTO dbo.Producto (
    CodigoProducto,
    Nombre,
    IdCategoria,
    Precio,
    Stock,
    RutaImagen
)
SELECT v.Codigo,
       v.Nombre,
       c.IdCategoria,
       v.Precio,
       v.Stock,
       v.Imagen
FROM   (VALUES (N'P001', N'Laptop Lenovo', N'Computadoras', 2500.00, 10, N'img/productos/P001.svg'), (N'P002', N'Mouse Logitech', N'Accesorios', 80.00, 25, N'img/productos/P002.svg'), (N'P003', N'Teclado Redragon', N'Accesorios', 150.00, 0, N'img/productos/P003.svg'), (N'P004', N'Mochila para laptop', N'Accesorios', 141.11, 0, N'img/productos/P004.svg'), (N'P005', N'Webcam Logitech C920', N'Accesorios', 102.25, 0, N'img/productos/P005.svg'), (N'P006', N'Hub USB-C 7 en 1', N'Accesorios', 113.33, 2, N'img/productos/P006.svg'), (N'P007', N'Laptop Asus Vivobook', N'Computadoras', 2677.83, 4, N'img/productos/P007.svg'), (N'P008', N'Impresora Canon Pixma', N'Impresoras', 718.04, 6, N'img/productos/P008.svg'), (N'P009', N'Impresora HP LaserJet', N'Impresoras', 704.03, 3, N'img/productos/P009.svg'), (N'P010', N'Laptop HP Pavilion', N'Computadoras', 2863.40, 8, N'img/productos/P010.svg'), (N'P011', N'Impresora Epson L3250', N'Impresoras', 412.85, 5, N'img/productos/P011.svg'), (N'P012', N'Monitor LG 24''''', N'Monitores', 467.83, 7, N'img/productos/P012.svg'), (N'P013', N'Access Point Ubiquiti', N'Redes', 376.64, 9, N'img/productos/P013.svg'), (N'P014', N'Mini PC Intel NUC', N'Computadoras', 2399.24, 4, N'img/productos/P014.svg'), (N'P015', N'Audifonos JBL', N'Accesorios', 176.73, 6, N'img/productos/P015.svg'), (N'P016', N'Monitor AOC 21.5''''', N'Monitores', 613.15, 3, N'img/productos/P016.svg'), (N'P017', N'Router TP-Link AX1800', N'Redes', 272.75, 5, N'img/productos/P017.svg'), (N'P018', N'Monitor Samsung 27''''', N'Monitores', 547.66, 2, N'img/productos/P018.svg'), (N'P019', N'Cable de red Cat6 (caja)', N'Redes', 144.11, 8, N'img/productos/P019.svg'), (N'P020', N'Repetidor Wifi TP-Link', N'Redes', 165.89, 4, N'img/productos/P020.svg')) AS v(Codigo, Nombre, Categoria, Precio, Stock, Imagen)
       INNER JOIN
       dbo.Categoria AS c
       ON c.NombreCategoria = v.Categoria;


GO
/* ==========================================================================
   3. VISTAS (reportes de la aplicación)
   ========================================================================== */
-- Reporte "Productos disponibles": solo productos activos con stock mayor que 0
CREATE VIEW dbo.vw_ProductosDisponibles
AS
SELECT p.CodigoProducto,
       p.Nombre,
       c.NombreCategoria,
       p.Precio,
       p.Stock,
       p.Estado,
       p.RutaImagen
FROM   dbo.Producto AS p
       INNER JOIN
       dbo.Categoria AS c
       ON c.IdCategoria = p.IdCategoria
WHERE  p.Activo = 1
       AND p.Stock > 0;


GO
-- Reporte "Resumen de productos": las mismas cifras de la pantalla Resumen
CREATE VIEW dbo.vw_ResumenInventario
AS
SELECT COUNT(*) AS TotalProductos,
       SUM(CASE WHEN Stock > 0 THEN 1 ELSE 0 END) AS Disponibles,
       SUM(CASE WHEN Stock = 0 THEN 1 ELSE 0 END) AS Agotados,
       CAST (SUM(Precio * Stock) AS DECIMAL (14, 2)) AS ValorInventario,
       SUM(Stock) AS StockTotal,
       CAST (ROUND (
                 100.0 * SUM (CASE WHEN Stock > 0 THEN 1 ELSE 0 END) / NULLIF (COUNT (*), 0),
                 0
             ) AS INT) AS DisponibilidadPct
FROM   dbo.Producto
WHERE  Activo = 1;


GO
-- Pantallas "Mis compras" (filtrando por usuario) y "Pedidos" (todos)
CREATE VIEW dbo.vw_PedidosDetalle
AS
SELECT pe.IdPedido,
       pe.NumeroPedido,
       pe.FechaPedido,
       u.IdUsuario,
       u.NombreUsuario,
       u.NombreCompleto AS Cliente,
       mp.NombreMetodo AS MetodoPago,
       d.CodigoProducto,
       pr.Nombre AS Producto,
       d.Cantidad,
       d.PrecioUnitario,
       d.Subtotal,
       pe.Total
FROM   dbo.Pedido AS pe
       INNER JOIN
       dbo.Usuario AS u
       ON u.IdUsuario = pe.IdUsuario
       INNER JOIN
       dbo.MetodoPago AS mp
       ON mp.IdMetodoPago = pe.IdMetodoPago
       INNER JOIN
       dbo.DetallePedido AS d
       ON d.IdPedido = pe.IdPedido
       INNER JOIN
       dbo.Producto AS pr
       ON pr.CodigoProducto = d.CodigoProducto;


GO
/* ==========================================================================
   4. PROCEDIMIENTOS ALMACENADOS
   ========================================================================== */
-- Crear la cuenta de un comprador (pantalla de registro)
CREATE PROCEDURE dbo.usp_RegistrarComprador
    @NombreUsuario VARCHAR (20),
    @Clave NVARCHAR (100),
    @NombreCompleto NVARCHAR (100),
    @Correo NVARCHAR (120),
    @IdUsuario INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF LEN(@Clave) < 6
        BEGIN
            THROW 50001, N'La contraseña debe tener al menos 6 caracteres.', 1;
        END
    IF EXISTS (SELECT 1
               FROM   dbo.Usuario
               WHERE  NombreUsuario = @NombreUsuario)
        BEGIN
            THROW 50002, N'Ese usuario ya está en uso. Elige otro.', 1;
        END
    INSERT  INTO dbo.Usuario (
        NombreUsuario,
        ClaveHash,
        NombreCompleto,
        Correo,
        IdRol
    )
    VALUES                   (@NombreUsuario, HASHBYTES('SHA2_256', @Clave), UPPER (
                                                                                 LTRIM (
                                                                                     RTRIM (@NombreCompleto)
                                                                                 )
                                                                             ), @Correo, (SELECT IdRol
                                                                                          FROM   dbo.Rol
                                                                                          WHERE  NombreRol = 'Comprador'));
    SET @IdUsuario = SCOPE_IDENTITY();
END


GO
-- Iniciar sesión: devuelve una fila si el usuario, la contraseña y el rol elegido coinciden
CREATE PROCEDURE dbo.usp_IniciarSesion
    @Rol VARCHAR (20),
    @NombreUsuario VARCHAR (20),
    @Clave NVARCHAR (100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.IdUsuario,
           u.NombreUsuario,
           u.NombreCompleto,
           r.NombreRol
    FROM   dbo.Usuario AS u
           INNER JOIN
           dbo.Rol AS r
           ON r.IdRol = u.IdRol
    WHERE  u.NombreUsuario = @NombreUsuario
           AND u.ClaveHash = HASHBYTES('SHA2_256', @Clave)
           AND r.NombreRol = @Rol
           AND u.Activo = 1;
END


GO
-- Agregar un producto al carrito sin superar el stock
CREATE PROCEDURE dbo.usp_AgregarAlCarrito
    @IdUsuario INT,
    @CodigoProducto VARCHAR (10),
    @Cantidad INT=1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @stock AS INT;
    DECLARE @actual AS INT;
    IF @Cantidad <= 0
        BEGIN
            THROW 50010, N'La cantidad debe ser mayor que 0.', 1;
        END
    IF NOT EXISTS (SELECT 1
                   FROM   dbo.Usuario AS u
                          INNER JOIN
                          dbo.Rol AS r
                          ON r.IdRol = u.IdRol
                   WHERE  u.IdUsuario = @IdUsuario
                          AND u.Activo = 1
                          AND r.NombreRol = 'Comprador')
        BEGIN
            THROW 50011, N'Solo un comprador activo puede usar el carrito.', 1;
        END
    SET @stock = (SELECT Stock
                  FROM   dbo.Producto
                  WHERE  CodigoProducto = @CodigoProducto
                         AND Activo = 1);
    IF @stock IS NULL
        BEGIN
            THROW 50012, N'El producto no existe.', 1;
        END
    IF @stock <= 0
        BEGIN
            THROW 50013, N'El producto está agotado.', 1;
        END
    SET @actual = ISNULL((SELECT Cantidad
                          FROM   dbo.ItemCarrito
                          WHERE  IdUsuario = @IdUsuario
                                 AND CodigoProducto = @CodigoProducto), 0);
    IF @actual + @Cantidad > @stock
        BEGIN
            THROW 50014, N'No hay stock suficiente para esa cantidad.', 1;
        END
    IF @actual = 0
        BEGIN
            INSERT  INTO dbo.ItemCarrito (
                IdUsuario,
                CodigoProducto,
                Cantidad
            )
            VALUES                       (@IdUsuario, @CodigoProducto, @Cantidad);
        END
    ELSE
        BEGIN
            UPDATE dbo.ItemCarrito
            SET    Cantidad = @actual + @Cantidad
            WHERE  IdUsuario = @IdUsuario
                   AND CodigoProducto = @CodigoProducto;
        END
END


GO
-- Finalizar la compra: valida el stock, crea el pedido, descuenta el stock y vacía el carrito.
-- Todo ocurre en una sola transacción: si algo falla, no se guarda nada.
CREATE PROCEDURE dbo.usp_FinalizarCompra
    @IdUsuario INT,
    @IdMetodoPago TINYINT,
    @IdPedido INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1
                       FROM   dbo.ItemCarrito
                       WHERE  IdUsuario = @IdUsuario)
            BEGIN
                THROW 50020, N'El carrito está vacío.', 1;
            END
        -- Bloquea los productos del carrito mientras se valida el stock
        IF EXISTS (SELECT 1
                   FROM   dbo.ItemCarrito AS ic
                          INNER JOIN
                          dbo.Producto AS p WITH (
                              UPDLOCK,
                              HOLDLOCK
                          )
                          ON p.CodigoProducto = ic.CodigoProducto
                   WHERE  ic.IdUsuario = @IdUsuario
                          AND (p.Activo = 0
                               OR ic.Cantidad > p.Stock))
            BEGIN
                THROW 50021, N'Uno o más productos no tienen stock suficiente o ya no están disponibles.', 1;
            END
        INSERT  INTO dbo.Pedido (
            IdUsuario,
            IdMetodoPago
        )
        VALUES                  (@IdUsuario, @IdMetodoPago);
        SET @IdPedido = SCOPE_IDENTITY();
        INSERT INTO dbo.DetallePedido (
            IdPedido,
            CodigoProducto,
            Cantidad,
            PrecioUnitario
        )
        SELECT @IdPedido,
               ic.CodigoProducto,
               ic.Cantidad,
               p.Precio
        FROM   dbo.ItemCarrito AS ic
               INNER JOIN
               dbo.Producto AS p
               ON p.CodigoProducto = ic.CodigoProducto
        WHERE  ic.IdUsuario = @IdUsuario;
        UPDATE p
        SET    p.Stock = p.Stock - ic.Cantidad
        FROM   dbo.Producto AS p
               INNER JOIN
               dbo.ItemCarrito AS ic
               ON ic.CodigoProducto = p.CodigoProducto
        WHERE  ic.IdUsuario = @IdUsuario;
        UPDATE dbo.Pedido
        SET    Total = (SELECT SUM(Subtotal)
                        FROM   dbo.DetallePedido
                        WHERE  IdPedido = @IdPedido)
        WHERE  IdPedido = @IdPedido;
        DELETE dbo.ItemCarrito
        WHERE  IdUsuario = @IdUsuario;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK;
            END;
        THROW;
    END CATCH
END


GO