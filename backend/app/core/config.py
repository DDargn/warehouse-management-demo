import os
from pathlib import Path

from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parents[2]
ENV_FILE = BASE_DIR / ".env"

load_dotenv(ENV_FILE)


class Settings:
    app_name: str = os.getenv("APP_NAME", "Warehouse Management API")
    app_version: str = os.getenv("APP_VERSION", "0.1.0")
    environment: str = os.getenv("ENVIRONMENT", "development")
    database_url: str = os.getenv(
        "DATABASE_URL",
        "postgresql+psycopg://warehouse_user:warehouse_password@localhost:5432/warehouse_db",
    )


settings = Settings()
