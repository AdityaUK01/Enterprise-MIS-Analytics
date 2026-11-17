
from pathlib import Path
import logging

import pandas as pd
from sqlalchemy import text

from python.config.database import get_engine

# Project directories
PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = PROJECT_ROOT / "python" / "output"
LOG_DIR = PROJECT_ROOT / "python" / "logs"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
LOG_DIR.mkdir(parents=True, exist_ok=True)

# Configure logging
logging.basicConfig(
    filename=LOG_DIR / "extraction.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

TABLES = [
    "Customers",
    "Employees",
    "Products",
    "Targets",
    "Orders"
]


def extract_table(engine, table_name):
    query = text(f"SELECT * FROM `{table_name}`")

    df = pd.read_sql(query, engine)

    output_file = OUTPUT_DIR / f"{table_name}.csv"
    df.to_csv(output_file, index=False)

    logging.info(
        "Extracted %s rows from %s",
        len(df),
        table_name
    )

    print(f"{table_name}: {len(df)} rows extracted")

    return df


def main():
    engine = get_engine()

    try:
        for table in TABLES:
            extract_table(engine, table)

        print("\nAll database tables extracted successfully.")

    except Exception:
        logging.exception("Data extraction failed")
        raise

    finally:
        engine.dispose()


if __name__ == "__main__":
    main()
