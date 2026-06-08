from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ProductBase(BaseModel):
    name: str = Field(min_length=1, max_length=150)
    sku: str = Field(min_length=1, max_length=80)
    category: str = Field(min_length=1, max_length=100)
    description: Optional[str] = None
    stock: int = Field(default=0, ge=0)
    min_stock: int = Field(default=0, ge=0)
    location: Optional[str] = None
    unit_price: Decimal = Field(default=Decimal("0.00"), ge=0)


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=150)
    sku: Optional[str] = Field(default=None, min_length=1, max_length=80)
    category: Optional[str] = Field(default=None, min_length=1, max_length=100)
    description: Optional[str] = None
    stock: Optional[int] = Field(default=None, ge=0)
    min_stock: Optional[int] = Field(default=None, ge=0)
    location: Optional[str] = None
    unit_price: Optional[Decimal] = Field(default=None, ge=0)


class ProductResponse(ProductBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
