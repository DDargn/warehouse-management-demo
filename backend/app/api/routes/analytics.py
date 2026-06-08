from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.product import Product
from app.models.stock_movement import StockMovement
from app.schemas.product import ProductResponse


router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/summary")
def get_analytics_summary(db: Session = Depends(get_db)):
    total_products = (
        db.query(func.count(Product.id))
        .filter(Product.is_active.is_(True))
        .scalar()
        or 0
    )

    total_stock_units = (
        db.query(func.coalesce(func.sum(Product.stock), 0))
        .filter(Product.is_active.is_(True))
        .scalar()
        or 0
    )

    low_stock_products = (
        db.query(func.count(Product.id))
        .filter(
            Product.is_active.is_(True),
            Product.stock < Product.min_stock,
        )
        .scalar()
        or 0
    )

    total_movements = db.query(func.count(StockMovement.id)).scalar() or 0

    stock_value = (
        db.query(func.coalesce(func.sum(Product.stock * Product.unit_price), 0))
        .filter(Product.is_active.is_(True))
        .scalar()
        or 0
    )

    categories_count = (
        db.query(func.count(func.distinct(Product.category)))
        .filter(Product.is_active.is_(True))
        .scalar()
        or 0
    )

    average_stock_per_product = (
        float(total_stock_units) / total_products if total_products > 0 else 0
    )

    return {
        "total_products": total_products,
        "total_stock_units": total_stock_units,
        "low_stock_products": low_stock_products,
        "total_movements": total_movements,
        "stock_value": float(stock_value),
        "categories_count": categories_count,
        "average_stock_per_product": round(average_stock_per_product, 2),
    }


@router.get("/stock-by-category")
def get_stock_by_category(db: Session = Depends(get_db)):
    rows = (
        db.query(
            Product.category.label("category"),
            func.count(Product.id).label("total_products"),
            func.coalesce(func.sum(Product.stock), 0).label("total_stock_units"),
            func.coalesce(func.sum(Product.stock * Product.unit_price), 0).label("stock_value"),
        )
        .filter(Product.is_active.is_(True))
        .group_by(Product.category)
        .order_by(Product.category)
        .all()
    )

    return [
        {
            "category": row.category,
            "total_products": row.total_products,
            "total_stock_units": row.total_stock_units,
            "stock_value": float(row.stock_value),
        }
        for row in rows
    ]


@router.get("/low-stock", response_model=list[ProductResponse])
def get_low_stock_products(db: Session = Depends(get_db)):
    return (
        db.query(Product)
        .filter(
            Product.is_active.is_(True),
            Product.stock < Product.min_stock,
        )
        .order_by(Product.stock.asc())
        .all()
    )
