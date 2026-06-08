from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field


class StockMovementCreate(BaseModel):
    product_id: int
    movement_type: Literal["IN", "OUT"]
    quantity: int = Field(gt=0)
    reason: Optional[str] = None


class StockMovementResponse(BaseModel):
    id: int
    product_id: int
    movement_type: str
    quantity: int
    reason: Optional[str]
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
