from fastapi import APIRouter

from app.core.config import settings
from app.db.database import check_database_connection


router = APIRouter(tags=["Health"])


@router.get("/health")
def health_check():
    return {
        "status": "ok",
        "app": settings.app_name,
        "version": settings.app_version,
        "environment": settings.environment,
    }


@router.get("/db-health")
def database_health_check():
    is_connected = check_database_connection()

    return {
        "status": "ok" if is_connected else "error",
        "database": "connected" if is_connected else "disconnected",
    }
