
from pathlib import Path
import logging

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = PROJECT_ROOT / "python" / "output"
LOG_DIR = PROJECT_ROOT / "python" / "logs"

LOG_DIR.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    filename=LOG_DIR / "transformation.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


def load_data():
    orders = pd.read_csv(DATA_DIR / "Orders.csv")
    customers = pd.read_csv(DATA_DIR / "Customers.csv")
    products = pd.read_csv(DATA_DIR / "Products.csv")
    employees = pd.read_csv(DATA_DIR / "Employees.csv")
    targets = pd.read_csv(DATA_DIR / "Targets.csv")

    return orders, customers, products, employees, targets


def transform_orders(orders):
    # Convert Excel serial dates if present
    if pd.api.types.is_numeric_dtype(orders["OrderDate"]):
        orders["OrderDate"] = pd.to_datetime(
            orders["OrderDate"],
            unit="D",
            origin="1899-12-30",
            errors="coerce"
        )
    else:
        orders["OrderDate"] = pd.to_datetime(
            orders["OrderDate"],
            errors="coerce"
        )

    numeric_columns = [
        "Quantity",
        "DiscountRate",
        "SalesAmount",
        "CostAmount"
    ]

    for column in numeric_columns:
        orders[column] = pd.to_numeric(
            orders[column],
            errors="coerce"
        )

    orders["Profit"] = (
        orders["SalesAmount"] - orders["CostAmount"]
    )

    orders["ProfitMargin"] = (
        orders["Profit"]
        .div(orders["SalesAmount"].replace(0, pd.NA))
        .mul(100)
    )

    orders["SalesMonth"] = orders["OrderDate"].dt.to_period("M").astype(str)

    return orders


def validate_data(orders):
    if orders["OrderID"].duplicated().any():
        raise ValueError("Duplicate OrderID values found")

    if orders["OrderDate"].isna().any():
        raise ValueError("Invalid or missing OrderDate values found")

    if orders["SalesAmount"].isna().any():
        raise ValueError("Missing or invalid SalesAmount values found")

    if orders["CostAmount"].isna().any():
        raise ValueError("Missing or invalid CostAmount values found")

    if (orders["Quantity"] <= 0).any():
        raise ValueError("Invalid Quantity values found")

    logging.info("Order data validation passed")


def main():
    orders, customers, products, employees, targets = load_data()

    print("Raw orders loaded:", len(orders))

    orders = transform_orders(orders)

    validate_data(orders)

    output_file = DATA_DIR / "Cleaned_Orders.csv"
    orders.to_csv(output_file, index=False)

    print("Cleaned orders saved:", output_file)
    print("Total orders:", len(orders))
    print("Total profit:", round(orders["Profit"].sum(), 2))
    print("Transformation and validation completed.")

    logging.info("Transformation completed successfully")


if __name__ == "__main__":
    main()
