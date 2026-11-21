# Enterprise Business Intelligence & MIS Automation System

## Project Overview

This project is designed to analyze business performance and automate Management Information System (MIS) reporting.

It uses SQL, Excel, Python, and Power BI to transform raw business data into meaningful reports and dashboards that support data-driven decision-making.

## Objectives

- Analyze sales, profit, and business performance.
- Monitor regional and employee performance.
- Track monthly sales against business targets.
- Analyze customers, products, and orders.
- Automate data extraction, transformation, and reporting.

## Tools & Technologies

- **SQL:** MySQL
- **Microsoft Excel:** Data analysis and MIS dashboards
- **Python:** Pandas, SQLAlchemy, OpenPyXL
- **Power BI:** Interactive dashboards and data visualization

## Dataset

The project uses a sample enterprise dataset containing:

- Customers: 300 records
- Employees: 24 records
- Products: 20 records
- Targets: 88 records
- Orders: 1,600 records

*Note: The dataset is for demonstration and portfolio purposes.*

## Project Structure

```text
Enterprise-MIS-Analytics/
│
├── Data/
│   ├── Raw/
│   └── excel/
│
├── sql/
│
├── python/
│   ├── config/
│   ├── extraction/
│   ├── transformation/
│   ├── reports/
│   ├── logs/
│   ├── output/
│   └── main.py
│
├── Enterprise-MIS-Analytics.pbix
│
└── README.md
```

## Key Features

- Business data analysis using SQL.
- Automated data extraction from MySQL.
- Data cleaning and transformation using Python.
- Automated Excel MIS report generation.
- Interactive Power BI dashboards.
- Sales, profit, regional, and employee performance analysis.

## How to Run

1. Clone or download this repository.
2. Install the required Python packages:

```bash
pip install -r python/requirements.txt
```

3. Configure your MySQL database credentials in the `.env` file.
4. Run the Python automation pipeline:

```bash
python -m python.main
```

5. Open the Power BI project file to explore the dashboard.

## Project Status

**Status:** In Progress

## Author

Aditya Rawat

