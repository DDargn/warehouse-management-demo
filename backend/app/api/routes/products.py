from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductResponse, ProductUpdate


router = APIRouter(prefix="/products", tags=["Products"])


@router.get("", response_model=list[ProductResponse])
def get_products(
    skip: int = 0,
    limit: int = Query(default=100, le=100),
    low_stock_only: bool = False,
    db: Session = Depends(get_db),
):
    query = db.query(Product).filter(Product.is_active.is_(True))

    if low_stock_only:
        query = query.filter(Product.stock < Product.min_stock)

    return query.order_by(Product.id).offset(skip).limit(limit).all()


@router.get("/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Session = Depends(get_db)):
    product = (
        db.query(Product)
        .filter(Product.id == product_id, Product.is_active.is_(True))
        .first()
    )

    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")

    return product


@router.post("", response_model=ProductResponse, status_code=201)
def create_product(product_data: ProductCreate, db: Session = Depends(get_db)):
    product = Product(**product_data.model_dump())

    try:
        db.add(product)
        db.commit()
        db.refresh(product)
        return product
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Product SKU already exists")


@router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    product_data: ProductUpdate,
    db: Session = Depends(get_db),
):
    product = (
        db.query(Product)
        .filter(Product.id == product_id, Product.is_active.is_(True))
        .first()
    )

    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")

    update_data = product_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(product, field, value)

    try:
        db.commit()
        db.refresh(product)
        return product
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Product SKU already exists")


@router.delete("/{product_id}", status_code=204)
def delete_product(product_id: int, db: Session = Depends(get_db)):
    product = (
        db.query(Product)
        .filter(Product.id == product_id, Product.is_active.is_(True))
        .first()
    )

    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")

    product.is_active = False
    db.commit()

    return None
