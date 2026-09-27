<%-- 
    Document   : index
    Created on : 19 sept 2026, 18:21:35
    Author     : USER
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Calculadoras UPLA</title>
    <link rel="stylesheet" href="css/Style.css">
</head>
<body>
    <div class="breadcrumb">Inicio</div>

    <div class="navbar">
        <a class="brand" href="index.jsp">
            <span class="badge-square">UPLA</span>
            <span class="logo-icon">&#9670;</span>
            <span class="brand-text">
                <div class="name">UPLA</div>
                <div class="sub">Universidad Peruana Los Andes</div>
            </span>
        </a>
        <span class="dot"></span>
    </div>

    <div class="container">
        <div class="rule"><span></span><span></span><span></span><span></span></div>
        <h1 class="page-title">Calculadoras de Geometría</h1>
        <p class="page-sub">Elige una calculadora para resolver y comprender la geometría de forma visual.</p>

        <div class="home-links">
            <a class="home-card" href="rectangulo.jsp">
                <div class="icon">&#9635;</div>
                <h3>Área y perímetro de un rectángulo</h3>
                <p>Ingresa la base y la altura para calcular el área y el perímetro de un rectángulo.</p>
            </a>

            <a class="home-card" href="hipotenusa.jsp">
                <div class="icon">&#9650;</div>
                <h3>Hipotenusa de un triángulo rectángulo</h3>
                <p>Aplica el teorema de Pitágoras a partir de la longitud de los dos catetos.</p>
            </a>
        </div>
    </div>

    <footer>
        <span>&copy; 2026 Universidad Peruana Los Andes</span>
        <a href="#">Soporte institucional</a>
    </footer>
</body>
</html>

