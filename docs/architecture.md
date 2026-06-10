# Arquitectura

Warehouse Management Demo es una aplicación full-stack dividida en tres capas principales:

## Frontend

Aplicación Flutter Web servida con Nginx.

Responsabilidades:

- Mostrar dashboard de KPIs.
- Gestionar productos mediante CRUD.
- Consumir la API REST de FastAPI.
- Representar datos reales almacenados en PostgreSQL.

## Backend

API REST desarrollada con FastAPI.

Responsabilidades:

- Exponer endpoints para productos, movimientos de stock y analítica.
- Validar datos de entrada.
- Aplicar reglas de negocio, como evitar salidas de stock superiores al inventario disponible.
- Consultar PostgreSQL mediante SQLAlchemy.

## Base de datos

PostgreSQL almacena la información principal del sistema.

Tablas principales:

- `products`
- `stock_movements`

## Flujo de datos

1. El usuario accede al frontend en `http://localhost:8080`.
2. Flutter Web consume la API en `http://127.0.0.1:8001`.
3. FastAPI procesa la petición.
4. SQLAlchemy consulta PostgreSQL.
5. La API devuelve JSON.
6. Flutter actualiza la interfaz.

## Servicios

| Servicio | Tecnología | Puerto |
|---|---|---|
| Frontend | Flutter Web + Nginx | 8080 |
| Backend | FastAPI + Uvicorn | 8001 |
| Base de datos | PostgreSQL | 5432 |

## Decisiones técnicas

- Docker Compose permite levantar PostgreSQL y el frontend de forma reproducible.
- Nginx sirve la build web de Flutter.
- FastAPI genera documentación automática con Swagger.
- PostgreSQL se inicializa con scripts SQL para facilitar las pruebas.
- El frontend usa `API_BASE_URL` mediante `--dart-define` para poder cambiar la URL del backend según el entorno.
