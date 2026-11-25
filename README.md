# Taller Clase 10 — Refactor de la API y despliegue en EC2

Autor: Oscar Henríquez — Equipo 03
Buenas Prácticas de Desarrollo de Software (CUC)

## Despliegue en EC2
- Instancia: `cuc-bp-eq03-henriquez-api`
- Security Group: `sg-cuc-bp-eq03-henriquez-api` (una sola regla de entrada: HTTP, TCP 80, origen 0.0.0.0/0; sin SSH)

## Estructura
- `antes/server.js` — API original entregada en clase (sin tocar).
- `despues/server.js` — API refactorizada (mismo comportamiento).
- `user-data.sh` — script que se pega en *User data* al lanzar la instancia EC2.

## Señales corregidas
| Señal | Antes | Después |
|---|---|---|
| Nombres sin significado | `s`, `d`, `t`, `p` | `servidor`, `notasDelCurso`, `suma`, `promedio` |
| Lógica repetida (DRY) | `writeHead` + `end` copiado 4 veces | función `responder(res, codigo, datos)` |
| Función que hace más de una cosa | el handler enruta, calcula y formatea | `calcularPromedio`, `estaAprobado`, `resumenDeNotas`, tabla `rutas`, `atenderPeticion` |
| Números sueltos | `3.0`, `80`, `200`, `404` | `NOTA_MINIMA`, `PUERTO`, `HTTP_OK`, `HTTP_NO_ENCONTRADO` |

## Contrato (no debe cambiar)
| Ruta | Código | Respuesta |
|---|---|---|
| /salud | 200 | `{ "estado": "ok" }` |
| /equipo | 200 | `{ "equipo": "Equipo 03", "integrantes": ["Oscar Henriquez"] }` |
| /notas | 200 | `{ "promedio": 3.625, "aprobado": true }` |
| otra | 404 | `{ "error": "Ruta no encontrada" }` |

## Probar en local
```
node antes/server.js     # luego abrir http://localhost/notas, cerrar con Ctrl+C
node despues/server.js   # repetir y comparar
```
