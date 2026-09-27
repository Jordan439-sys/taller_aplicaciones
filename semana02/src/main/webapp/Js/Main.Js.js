/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
// ---------- Utilidades ----------
function unidadTexto(select) {
    return select ? select.value : "m";
}

function mostrarError(contenedorId, mensaje) {
    document.getElementById(contenedorId).innerHTML =
        '<div class="result-error">' + mensaje + '</div>';
}

// ---------- Rectángulo ----------
function calcularRectangulo() {
    var base = parseFloat(document.getElementById("baseRect").value);
    var altura = parseFloat(document.getElementById("alturaRect").value);
    var unidad = unidadTexto(document.getElementById("unitRect"));

    if (isNaN(base) || isNaN(altura) || base <= 0 || altura <= 0) {
        mostrarError("resultados", "Ingresa una base y una altura válidas (mayores que cero).");
        dibujarRectangulo(0, 0);
        return;
    }

    var area = base * altura;
    var perimetro = 2 * (base + altura);

    document.getElementById("resultados").innerHTML =
        '<div class="result-box">' +
            '<div class="r-label">Área</div>' +
            '<div class="r-value">' + area.toFixed(2) + ' ' + unidad + '&sup2;</div>' +
        '</div>' +
        '<div class="result-box">' +
            '<div class="r-label">Perímetro</div>' +
            '<div class="r-value">' + perimetro.toFixed(2) + ' ' + unidad + '</div>' +
        '</div>';

    dibujarRectangulo(base, altura, unidad);
}

function dibujarRectangulo(base, altura, unidad) {
    var rect = document.getElementById("rectShape");
    var lblBase = document.getElementById("lblBase");
    var lblAltura = document.getElementById("lblAltura");

    if (!base || !altura) {
        rect.setAttribute("width", 0);
        rect.setAttribute("height", 0);
        lblBase.textContent = "";
        lblAltura.textContent = "";
        return;
    }

    var maxW = 180, maxH = 180;
    var escala = Math.min(maxW / base, maxH / altura);
    var w = base * escala;
    var h = altura * escala;
    var x = (220 - w) / 2;
    var y = (220 - h) / 2;

    rect.setAttribute("x", x);
    rect.setAttribute("y", y);
    rect.setAttribute("width", w);
    rect.setAttribute("height", h);

    lblBase.textContent = base.toFixed(2) + " " + (unidad || "m");
    lblBase.style.left = (x + w / 2) + "px";
    lblBase.style.bottom = (220 - y - h - 22) + "px";

    lblAltura.textContent = altura.toFixed(2) + " " + (unidad || "m");
    lblAltura.style.top = (y + h / 2) + "px";
    lblAltura.style.left = (x - 8) + "px";
}

// ---------- Hipotenusa ----------
function calcularHipotenusa() {
    var catA = parseFloat(document.getElementById("catetoA").value);
    var catB = parseFloat(document.getElementById("catetoB").value);
    var unidad = unidadTexto(document.getElementById("unitHip"));

    if (isNaN(catA) || isNaN(catB) || catA <= 0 || catB <= 0) {
        mostrarError("resultadosHip", "Ingresa catetos válidos (mayores que cero).");
        dibujarTriangulo(0, 0);
        return;
    }

    var hip = Math.sqrt(catA * catA + catB * catB);
    var esExacta = Math.abs(hip - Math.round(hip)) < 0.0001;

    document.getElementById("resultadosHip").innerHTML =
        '<div class="result-box">' +
            '<div class="r-label">Hipotenusa</div>' +
            '<div class="r-value">' + hip.toFixed(2) + ' ' + unidad +
                (esExacta ? '<span class="exact-tag">RESULTADO EXACTO</span>' : '') +
            '</div>' +
        '</div>';

    dibujarTriangulo(catA, catB, unidad);
}

function dibujarTriangulo(catA, catB, unidad) {
    var poly = document.getElementById("triShape");
    var lblA = document.getElementById("lblCatA");
    var lblB = document.getElementById("lblCatB");
    var lblH = document.getElementById("lblHip");

    if (!catA || !catB) {
        poly.setAttribute("points", "");
        lblA.textContent = "";
        lblB.textContent = "";
        lblH.textContent = "";
        return;
    }

    var maxW = 160, maxH = 160;
    var escala = Math.min(maxW / catB, maxH / catA);
    var w = catB * escala;
    var h = catA * escala;

    var originX = 40;
    var originY = 190;

    var px = originX;
    var py = originY;
    var qx = originX + w;
    var qy = originY;
    var rx = originX;
    var ry = originY - h;

    poly.setAttribute("points", px + "," + py + " " + qx + "," + qy + " " + rx + "," + ry);

    lblB.textContent = catB.toFixed(2) + " " + (unidad || "m");
    lblB.style.left = (px + w / 2 - 20) + "px";
    lblB.style.top = (py + 6) + "px";

    lblA.textContent = catA.toFixed(2) + " " + (unidad || "m");
    lblA.style.left = (rx - 46) + "px";
    lblA.style.top = (ry + h / 2) + "px";

    var hip = Math.sqrt(catA * catA + catB * catB);
    lblH.textContent = hip.toFixed(2) + " " + (unidad || "m");
    lblH.style.left = (rx + w / 2 - 10) + "px";
    lblH.style.top = (ry + h / 2 - 10) + "px";
}



