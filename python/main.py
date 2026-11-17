
import logging

from python.extraction.extract_data import main as extract_data
from python.transformation.transform_data import main as transform_data
from python.reports.generate_report import main as generate_report

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)


def main():
    logging.info("Starting Enterprise MIS Automation Pipeline")

    try:
        logging.info("STEP 1: Data Extraction")
        extract_data()

        logging.info("STEP 2: Data Transformation")
        transform_data()

        logging.info("STEP 3: MIS Report Generation")
        generate_report()

        logging.info("MIS Automation Pipeline completed successfully!")

    except Exception:
        logging.exception("MIS Automation Pipeline failed")
        raise


if __name__ == "__main__":
    main()
