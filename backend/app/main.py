from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.analytics import router as analytics_router
from app.api.routes.health import router as health_router
from app.api.routes.products import router as products_router
from app.api.routes.stock_movements import router as stock_movements_router
from app.core.config import settings


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
)

allowed_origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health_router)
app.include_router(products_router, prefix="/api")
app.include_router(stock_movements_router, prefix="/api")
app.include_router(analytics_router, prefix="/api")


@app.get("/")
def root():
    return {
        "message": "Warehouse Management API",
        "docs": "/docs",
        "health": "/health",
        "db_health": "/db-health",
        "products": "/api/products",
        "stock_movements": "/api/stock-movements",
        "analytics": "/api/analytics/summary",
    }
