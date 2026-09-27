<%-- 
    Document   : rectangulo
    Created on : 26 sept 2026, 19:26:12
    Author     : USER
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rectángulo - UPLA</title>
    <link rel="stylesheet" href="css/Stile.css">
</head>
<body>
    <div style="width: 100%; max-width: 850px;">
        <a href="index.jsp" class="back-link">← Volver al inicio</a>

        <main class="card theme-orange">
            <header class="card-header">
                <h2>Rectángulo</h2>
                <img src="img/logo.png" alt="Logo UPLA" class="card-logo">
            </header>

            <div class="card-subheader">
                <span>Calcula el área y perímetro de un rectángulo.</span>
                <div class="unit-selector">
                    <label for="unitRect">Unidad:</label>
                    <select id="unitRect">
                        <option value="m">Metros (m)</option>
                        <option value="cm">Centímetros (cm)</option>
                    </select>
                </div>
            </div>

            <div class="card-body">
                <!-- Columna Izquierda: Entradas de Texto -->
                <div class="form-section">
                    <div class="form-group">
                        <label for="baseRect">Base</label>
                        <input type="number" id="baseRect" placeholder="5" min="0" step="any">
                    </div>
                    <div class="form-group">
                        <label for="alturaRect">Altura</label>
                        <input type="number" id="alturaRect" placeholder="10" min="0" step="any">
                    </div>

                    <button class="btn btn-orange" onclick="calcularRectangulo()">Calcular</button>

                    <div id="resultados" class="result-container"></div>
                </div>

                <!-- Columna Derecha: Canvas Dinámico de Vista Previa -->
                <div class="preview-box">
                    <span class="preview-title">Vista Previa</span>

                    <div class="svg-container">
                        <svg width="220" height="220">
                            <rect id="rectShape" x="110" y="110" width="0" height="0" fill="#f97316" rx="4" />
                        </svg>
                        <span id="lblAltura" class="label-v" style="top: 50%;"></span>
                        <span id="lblBase" class="label-h" style="left: 50%; transform: translateX(-50%);"></span>
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
