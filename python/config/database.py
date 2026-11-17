
import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

PROJECT_ROOT = Path(__file__).resolve().parents[2]
load_dotenv(PROJECT_ROOT / "python" / ".env")

def get_engine():
    required = ["DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASSWORD"]

    missing = [key for key in required if os.getenv(key) is None]
    if missing:
        raise ValueError(f"Missing database settings: {', '.join(missing)}")

    connection_url = URL.create(
        drivername="mysql+pymysql",
        username=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT")),
        database=os.getenv("DB_NAME"),
    )

    return create_engine(
        connection_url,
        pool_pre_ping=True
    )

def test_connection():
    engine = get_engine()

    with engine.connect() as connection:
        result = connection.execute(text("SELECT DATABASE()"))
        database_name = result.scalar_one()

    print(f"Successfully connected to database: {database_name}")

if __name__ == "__main__":
    test_connection()
