from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = FastAPI()

# Model to represent the data received in the POST request
class Item(BaseModel):
    username: str
    text: str

# In-memory storage to keep items added via POST requests
items: List[Item] = []

@app.post("/add")
def add_item(item: Item):
    """Receives an item with username and text and adds it to the list."""
    items.append(item)
    return {"message": "Item added successfully"}

@app.get("/list", response_model=List[Item])
def list_items():
    """Returns the list of all items added through /add endpoint."""
    return items
