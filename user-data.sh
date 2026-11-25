#!/bin/bash
dnf install -y nodejs
mkdir -p /opt/api

cat > /opt/api/server.js <<'FIN'
const http = require('http');

// ---------- Configuración (números con nombre) ----------
const PUERTO = 80;
const NOTA_MINIMA = 3.0;
const HTTP_OK = 200;
const HTTP_NO_ENCONTRADO = 404;

// ---------- Datos: de dónde salen las notas ----------
const notasDelCurso = [4.5, 3.5, 2.5, 4.0];
const datosDelEquipo = {
  equipo: 'Equipo 03',
  integrantes: ['Oscar Henriquez']
};

// ---------- Lógica: no sabe nada de HTTP ----------
function calcularPromedio(notas) {
  return notas.reduce((suma, nota) => suma + nota, 0) / notas.length;
}

function estaAprobado(promedio) {
  return promedio >= NOTA_MINIMA;
}

function resumenDeNotas(notas) {
  const promedio = calcularPromedio(notas);
  return { promedio: promedio, aprobado: estaAprobado(promedio) };
}

// ---------- Presentación: una sola forma de responder ----------
function responder(res, codigo, datos) {
  res.writeHead(codigo, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(datos, null, 2));
}

// ---------- Rutas: cada una hace una sola cosa ----------
const rutas = {
  '/salud': () => ({ estado: 'ok' }),
  '/equipo': () => datosDelEquipo,
  '/notas': () => resumenDeNotas(notasDelCurso)
};

function atenderPeticion(req, res) {
  const manejador = rutas[req.url];
  if (manejador) {
    responder(res, HTTP_OK, manejador());
  } else {
    responder(res, HTTP_NO_ENCONTRADO, { error: 'Ruta no encontrada' });
  }
}

const servidor = http.createServer(atenderPeticion);
servidor.listen(PUERTO);
FIN

cat > /etc/systemd/system/api.service <<'FIN'
[Unit]
Description=API del equipo
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/api/server.js
Restart=always

[Install]
WantedBy=multi-user.target
FIN

systemctl daemon-reload
systemctl enable --now api