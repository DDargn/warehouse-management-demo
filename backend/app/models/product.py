from sqlalchemy import Boolean, Column, DateTime, Integer, Numeric, String, Text, func
from sqlalchemy.orm import relationship

from app.db.database import Base


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    sku = Column(String(80), unique=True, nullable=False, index=True)
    category = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    stock = Column(Integer, nullable=False, default=0)
    min_stock = Column(Integer, nullable=False, default=0)
    location = Column(String(100), nullable=True)
    unit_price = Column(Numeric(10, 2), nullable=False, default=0)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )

    movements = relationship("StockMovement", back_populates="product")
