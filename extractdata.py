import os
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import pandas as pd  # pip install pandas
import sqlalchemy as sa  # pip install sqlalchemy
from sqlalchemy.engine import URL

"""
This script connects to a SQL Server database using credentials from a .env file,
extracts data, and saves it to an Excel file.
The .env file should contain the following variables:
- SQL_SERVER: The hostname or IP address of the SQL Server instance.
- SQL_DATABASE: The name of the database to connect to.
- SQL_USERNAME: The username for authentication.
- SQL_PASSWORD: The password for authentication.
- SQL_DRIVER (optional): The ODBC driver to use (default: "ODBC Driver 17 for SQL Server").
- SQL_ENCRYPT (optional): Whether to encrypt the connection (default: "yes").
- SQL_TRUST_SERVER_CERTIFICATE (optional): Whether to trust the server certificate (default: "no").
- EXCEL_PATH (optional): The directory to save the Excel file (default: "output").
- EXCEL_FILE_NAME (optional): The name of the Excel file (default: "extract.xlsx").
- PROJECT_NAME (optional): A value to include in the extracted data (default: "Gauthier").
"""

def load_dotenv_file(path: Path) -> Dict[str, str]:
    values: Dict[str, str] = {}
    if not path.exists() or not path.is_file():
        return values

    for raw_line in path.read_text(encoding="utf-8-sig").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.lower().startswith("export "):
            line = line[7:].strip()
        if "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if not key:
            continue

        if (value.startswith('"') and value.endswith('"')) or (
            value.startswith("'") and value.endswith("'")
        ):
            value = value[1:-1]
        values[key] = value

    return values


def first_non_empty(*values: Optional[str]) -> Optional[str]:
    for value in values:
        if value is not None and value != "":
            return value
    return None


def parse_bool(value: Optional[str], default: bool = False) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "y", "on"}


def get_config_value(dotenv_values: Dict[str, str], *keys: str) -> Optional[str]:
    for key in keys:
        env_value = os.environ.get(key)
        if env_value is not None and env_value != "":
            return env_value
        file_value = dotenv_values.get(key)
        if file_value is not None and file_value != "":
            return file_value
    return None


def build_engine_from_env(dotenv_values: Dict[str, str]) -> sa.Engine:
    server = get_config_value(dotenv_values, "SQL_SERVER")
    database = get_config_value(dotenv_values, "SQL_DATABASE")
    username = get_config_value(dotenv_values, "SQL_USERNAME")
    password = get_config_value(dotenv_values, "SQL_PASSWORD")
    driver = first_non_empty(get_config_value(dotenv_values, "SQL_DRIVER"), "ODBC Driver 17 for SQL Server")

    missing = [
        name
        for name, value in (
            ("SQL_SERVER", server),
            ("SQL_DATABASE", database),
            ("SQL_USERNAME", username),
            ("SQL_PASSWORD", password),
        )
        if not value
    ]
    if missing:
        raise ValueError(f"Missing required .env values: {', '.join(missing)}")

    encrypt = first_non_empty(get_config_value(dotenv_values, "SQL_ENCRYPT"), "yes")
    trust_cert = parse_bool(get_config_value(dotenv_values, "SQL_TRUST_SERVER_CERTIFICATE"), default=False)

    connect_args = {
        "driver": driver,
        "Encrypt": encrypt,
        "TrustServerCertificate": "yes" if trust_cert else "no",
    }

    connection_url = URL.create(
        "mssql+pyodbc",
        username=username,
        password=password,
        host=server,
        database=database,
        query=connect_args,
    )
    return sa.create_engine(connection_url)


def resolve_excel_output(dotenv_values: Dict[str, str]) -> Path:
    excel_dir = first_non_empty(get_config_value(dotenv_values, "EXCEL_PATH"), "output")
    excel_file = first_non_empty(get_config_value(dotenv_values, "EXCEL_FILE_NAME"), "extract.xlsx")

    output_dir = Path(excel_dir)
    if not output_dir.is_absolute():
        output_dir = Path.cwd() / output_dir

    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir / excel_file


def build_queries(table_mappings: List[Tuple[str, str]]) -> List[Tuple[sa.TextClause, str]]:
    queries: List[Tuple[sa.TextClause, str]] = []
    for table_name, sheet_name in table_mappings:
        sql = sa.text(
            f"SELECT *, :project_name AS Project, GETDATE() AS [Timestamp] FROM {table_name}"
        )
        queries.append((sql, sheet_name))
    return queries


if __name__ == "__main__":
    dotenv_values = load_dotenv_file(Path(".env"))

    project_name = first_non_empty(get_config_value(dotenv_values, "PROJECT_NAME"), "Gauthier")

    table_mappings = [
        ("T_MasterCustomers", "MasterCustomers"),
        ("T_Customers", "Customers"),
        ("T_CustomerLocations", "CustomerLocations"),
        ("T_Contacts", "Contacts"),
        ("T_ContactLocations", "ContactLocations"),
        ("T_CustomerServiceAgreementHeader", "CustomerServiceAgreementHeader"),
        ("T_CustomerServiceAgreementPrices", "CustomerServiceAgreementPrices"),
        ("T_SiteOrderHeader", "SiteOrderHeader"),
        ("T_SiteOrderItems", "SiteOrderItems"),
        ("T_SiteOrderRental", "SiteOrderRental"),
        ("T_SiteOrderAssignments", "SiteOrderAssignments"),
        ("T_Routing", "Routing"),
        ("T_Containers", "Containers"),
        ("T_CallLog", "CallLog"),
        ("T_AgedDebtorsData", "AgedDebtorsData"),
    ]
    queries = build_queries(table_mappings)

    try:
        engine = build_engine_from_env(dotenv_values)
    except ValueError as ex:
        raise SystemExit(str(ex)) from ex

    excel_file_path = resolve_excel_output(dotenv_values)
    print(f"Writing Excel output to: {excel_file_path}")

    start_time = pd.Timestamp.now()
    success_sheets: List[str] = []
    failed_sheets: List[Tuple[str, str]] = []

    with engine.connect() as conn, pd.ExcelWriter(excel_file_path) as writer:
        for query, sheet_name in queries:
            try:
                df = pd.read_sql_query(query, conn, params={"project_name": project_name})
                df.to_excel(writer, sheet_name=sheet_name, index=False)
                success_sheets.append(sheet_name)
                print(f"SUCCESS: {sheet_name} ({len(df)} rows)")
            except Exception as ex:
                failed_sheets.append((sheet_name, str(ex)))
                print(f"FAILED: {sheet_name} -> {ex}")

    engine.dispose()

    end_time = pd.Timestamp.now()
    print("\nExtraction summary")
    print(f"Completed in: {end_time - start_time}")
    print(f"Successful sheets: {len(success_sheets)}")
    print(f"Failed sheets: {len(failed_sheets)}")
    if failed_sheets:
        print("Failures:")
        for sheet_name, error in failed_sheets:
            print(f"- {sheet_name}: {error}")