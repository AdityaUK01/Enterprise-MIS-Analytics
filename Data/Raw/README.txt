# Enterprise MIS Analytics Dataset

All records are fictional and generated for portfolio learning.

## Files
- Orders.csv: order-line transactions; one row per order.
- Products.csv: product master, unit cost/price and stock.
- Customers.csv: customer master and region.
- Employees.csv: employee master, department and region.
- Targets.csv: monthly sales targets by region.

## Key relationships
- Orders.CustomerID -> Customers.CustomerID
- Orders.ProductID -> Products.ProductID
- Orders.EmployeeID -> Employees.EmployeeID
- Targets joins to aggregated Orders by month and region (derive region through Customers).

## Notes
- Dates span 2025-01-01 through 2026-10-12.
- SalesAmount is after discount.
- CostAmount is quantity multiplied by unit cost.
- Profit can be derived as SalesAmount - CostAmount.
- OrderStatus includes Delivered and Returned records. Decide and document how returns should be treated in each KPI.
- Dataset is synthetic; do not interpret it as real market data.
