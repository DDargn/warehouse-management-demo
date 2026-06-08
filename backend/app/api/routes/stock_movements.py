from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.product import Product
from app.models.stock_movement import StockMovement
from app.schemas.stock_movement import StockMovementCreate, StockMovementResponse


router = APIRouter(prefix="/stock-movements", tags=["Stock Movements"])


@router.get("", response_model=list[StockMovementResponse])
def get_stock_movements(
    skip: int = 0,
    limit: int = Query(default=100, le=100),
    db: Session = Depends(get_db),
):
    return (
        db.query(StockMovement)
        .order_by(StockMovement.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


@router.post("", response_model=StockMovementResponse, status_code=201)
def create_stock_movement(
    movement_data: StockMovementCreate,
    db: Session = Depends(get_db),
):
    product = (
        db.query(Product)
        .filter(Product.id == movement_data.product_id, Product.is_active.is_(True))
        .first()
    )

    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")

    if movement_data.movement_type == "OUT":
        if product.stock < movement_data.quantity:
            raise HTTPException(
                status_code=400,
                detail="Not enough stock for this movement",
            )

        product.stock -= movement_data.quantity

    if movement_data.movement_type == "IN":
        product.stock += movement_data.quantity

    movement = StockMovement(**movement_data.model_dump())

    db.add(movement)
    db.commit()
    db.refresh(movement)

    return movement
