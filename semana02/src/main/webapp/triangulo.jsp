<%-- 
    Document   : triangulo
    Created on : 26 sept 2026, 19:26:54
    Author     : USER
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hipotenusa - UPLA</title>
    <link rel="stylesheet" href="css/Style.css">
</head>
<body>
    <div style="width: 100%; max-width: 850px;">
        <a href="index.jsp" class="back-link">← Volver al inicio</a>

        <main class="card theme-teal">
            <header class="card-header">
                <h2>Hipotenusa</h2>
                <img src="img/logo.png" alt="Logo UPLA" class="card-logo">
            </header>

            <div class="card-subheader">
                <span>Aplica el teorema de Pitágoras a partir de los catetos.</span>
                <div class="unit-selector">
                    <label for="unitHip">Unidad:</label>
                    <select id="unitHip">
                        <option value="m">Metros (m)</option>
                        <option value="cm">Centímetros (cm)</option>
                    </select>
                </div>
            </div>

            <div class="card-body">
                <!-- Columna Izquierda: Entradas de Texto -->
                <div class="form-section">
                    <div class="form-group">
                        <label for="catetoA">Cateto A</label>
                        <input type="number" id="catetoA" placeholder="9" min="0" step="any">
                    </div>
                    <div class="form-group">
                        <label for="catetoB">Cateto B</label>
                        <input type="number" id="catetoB" placeholder="12" min="0" step="any">
                    </div>

                    <button class="btn btn-teal" onclick="calcularHipotenusa()">Calcular</button>

                    <div id="resultadosHip" class="result-container"></div>
                </div>

                <!-- Columna Derecha: Vista Previa dinámica -->
                <div class="preview-box">
                    <span class="preview-title">Vista Previa</span>

                    <div class="svg-container">
                        <svg width="220" height="220">
                            <polygon id="triShape" points="" fill="#ccfbf1" stroke="#0d9488" stroke-width="2" />
                        </svg>
                        <span id="lblCatA" class="label-v" style="top: 50%;"></span>
                        <span id="lblCatB" class="label-h" style="left: 50%;"></span>
                        <span id="lblHip" class="label-h" style="left: 50%;"></span>
                    </div>
                </div>
            </div>
        </main>

        <footer class="page-footer">
            <span>&copy; 2026 Universidad Peruana Los Andes</span>
            <a href="#">Soporte institucional</a>
        </footer>
    </div>
    <script src="js/main.js"></script>
</body>
</html>
