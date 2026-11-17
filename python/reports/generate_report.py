
from pathlib import Path

import pandas as pd
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = PROJECT_ROOT / "python" / "output"

INPUT_FILE = OUTPUT_DIR / "Cleaned_Orders.csv"
CUSTOMERS_FILE = OUTPUT_DIR / "Customers.csv"
PRODUCTS_FILE = OUTPUT_DIR / "Products.csv"
EMPLOYEES_FILE = OUTPUT_DIR / "Employees.csv"

REPORT_FILE = OUTPUT_DIR / "Automated_MIS_Report.xlsx"


def load_data():
    orders = pd.read_csv(INPUT_FILE, parse_dates=["OrderDate"])
    customers = pd.read_csv(CUSTOMERS_FILE)
    products = pd.read_csv(PRODUCTS_FILE)
    employees = pd.read_csv(EMPLOYEES_FILE)

    return orders, customers, products, employees


def generate_reports(orders, customers, products, employees):

    delivered = orders[orders["OrderStatus"] == "Delivered"].copy()

    # Executive KPIs
    kpis = pd.DataFrame({
        "Metric": [
            "Total Orders",
            "Delivered Orders",
            "Returned Orders",
            "Delivered Sales",
            "Delivered Gross Profit",
            "Return Rate (%)"
        ],
        "Value": [
            len(orders),
            len(delivered),
            (orders["OrderStatus"] == "Returned").sum(),
            delivered["SalesAmount"].sum(),
            delivered["Profit"].sum(),
            (orders["OrderStatus"] == "Returned").mean() * 100
        ]
    })

    # Monthly performance
    monthly = (
        delivered.groupby("SalesMonth")
        .agg(
            Orders=("OrderID", "count"),
            Sales=("SalesAmount", "sum"),
            GrossProfit=("Profit", "sum")
        )
        .reset_index()
    )

    # Regional performance
    regional_data = delivered.merge(
        customers[["CustomerID", "Region"]],
        on="CustomerID",
        how="left",
        validate="many_to_one"
    )

    regional = (
        regional_data.groupby("Region")
        .agg(
            Orders=("OrderID", "count"),
            Sales=("SalesAmount", "sum"),
            GrossProfit=("Profit", "sum")
        )
        .reset_index()
    )

    # Employee performance
    employee_data = delivered.merge(
        employees[["EmployeeID", "EmployeeName", "Region"]],
        on="EmployeeID",
        how="left",
        validate="many_to_one"
    )

    employee_report = (
        employee_data.groupby(
            ["EmployeeID", "EmployeeName", "Region"]
        )
        .agg(
            Orders=("OrderID", "count"),
            Sales=("SalesAmount", "sum"),
            GrossProfit=("Profit", "sum")
        )
        .reset_index()
        .sort_values("Sales", ascending=False)
    )

    # Product performance
    product_data = delivered.merge(
        products[["ProductID", "ProductName", "Category"]],
        on="ProductID",
        how="left",
        validate="many_to_one"
    )

    product_report = (
        product_data.groupby(
            ["ProductID", "ProductName", "Category"]
        )
        .agg(
            UnitsSold=("Quantity", "sum"),
            Sales=("SalesAmount", "sum"),
            GrossProfit=("Profit", "sum")
        )
        .reset_index()
        .sort_values("Sales", ascending=False)
    )

    # Order status
    status_report = (
        orders.groupby("OrderStatus")
        .agg(
            Orders=("OrderID", "count"),
            Sales=("SalesAmount", "sum"),
            GrossProfit=("Profit", "sum")
        )
        .reset_index()
    )

    return {
        "Executive Summary": kpis,
        "Monthly Performance": monthly,
        "Regional Performance": regional,
        "Employee Performance": employee_report,
        "Product Performance": product_report,
        "Order Status": status_report
    }


def format_workbook(file_path):

    workbook = load_workbook(file_path)

    for sheet in workbook.worksheets:
        sheet.freeze_panes = "A2"
        sheet.auto_filter.ref = sheet.dimensions

        for cell in sheet[1]:
            cell.font = Font(bold=True, color="FFFFFF")
            cell.fill = PatternFill(
                fill_type="solid",
                fgColor="1F4E78"
            )
            cell.alignment = Alignment(horizontal="center")

        for column_cells in sheet.columns:
            max_length = max(
                len(str(cell.value or ""))
                for cell in column_cells
            )
            column_letter = get_column_letter(
                column_cells[0].column
            )
            sheet.column_dimensions[column_letter].width = min(
                max_length + 3, 35
            )

    workbook.save(file_path)


def main():

    orders, customers, products, employees = load_data()

    reports = generate_reports(
        orders, customers, products, employees
    )

    with pd.ExcelWriter(REPORT_FILE, engine="openpyxl") as writer:
        for sheet_name, dataframe in reports.items():
            dataframe.to_excel(
                writer,
                sheet_name=sheet_name,
                index=False
            )

    format_workbook(REPORT_FILE)

    print("Automated MIS report generated successfully!")
    print(f"Report location: {REPORT_FILE}")
    print("Total worksheets:", len(reports))


if __name__ == "__main__":
    main()
