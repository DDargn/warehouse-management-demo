# Warehouse Manager Demo

Demo web de gestión de almacén construida con Flutter Web, FastAPI, PostgreSQL y Docker.

## Funcionalidades

- Dashboard con KPIs de stock
- CRUD de productos
- Entradas y salidas de inventario
- Historial de movimientos
- Alertas de stock bajo
- Datos de prueba precargados
- API documentada con Swagger
- Despliegue local con Docker Compose

## Stack técnico

- Flutter Web
- FastAPI
- PostgreSQL
- Docker
- Docker Compose
- Nginx

## Requisitos

- Docker
- Docker Compose

No es necesario tener Flutter ni Python instalados para ejecutar la demo con Docker.

## Instalación rápida

```bash
git clone https://github.com/tuusuario/warehouse-manager-demo.git
cd warehouse-manager-demo
cp .env.example .env
docker compose up --build
