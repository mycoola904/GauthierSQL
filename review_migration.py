#!/usr/bin/env python3
"""Generate an Excel/Markdown migration review report from SQL query batches."""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import pandas as pd
import pyodbc
import sqlalchemy as sa
from sqlalchemy.engine import URL

GO_PATTERN = re.compile(r"^\s*GO(?:\s+(\d+))?\s*(?:--.*)?$", re.IGNORECASE)
REPORT_NAME_PATTERN = re.compile(r"^\s*--\s*report\s*:\s*(.+?)\s*$", re.IGNORECASE | re.MULTILINE)
SHEET_NAME_PATTERN = re.compile(r"^\s*--\s*sheet\s*:\s*(.+?)\s*$", re.IGNORECASE | re.MULTILINE)


@dataclass
class QueryBatch:
    name: str
    sql: str
    sheet_name: Optional[str] = None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run review SQL and generate a customer migration report."
    )
    parser.add_argument(
        "--sql-file",
        default="sql\\review\\review_customers_report.sql",
        help="Path to SQL file containing query batches separated by GO",
    )
    parser.add_argument(
        "--output-dir",
        default="excel\\review",
        help="Directory where report files are written",
    )
    parser.add_argument(
        "--output-prefix",
        default="customer_migration_review",
        help="Prefix for generated report files",
    )
    parser.add_argument("--env-file", default=".env", help="Path to .env file")
    parser.add_argument("--server", help="SQL Server name or host")
    parser.add_argument("--database", help="Default database")
    parser.add_argument("--driver", help="ODBC driver; auto-detected when omitted")
    parser.add_argument("--username", help="SQL login username (omit for Windows auth)")
    parser.add_argument("--password", help="SQL login password")
    parser.add_argument("--encrypt", choices=["yes", "no"], default=None)
    parser.add_argument(
        "--trust-server-certificate",
        action="store_true",
        help="Set TrustServerCertificate=yes",
    )
    return parser.parse_args()


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


def from_env(file_values: Dict[str, str], *keys: str) -> Optional[str]:
    for key in keys:
        env_value = os.environ.get(key)
        if env_value:
            return env_value
        file_value = file_values.get(key)
        if file_value:
            return file_value
    return None


def resolve_connection_settings(args: argparse.Namespace) -> None:
    file_values = load_dotenv_file(Path(args.env_file))

    args.server = first_non_empty(
        args.server,
        from_env(file_values, "SQL_SERVER", "MSSQL_SERVER", "DB_SERVER", "SERVER"),
    )
    args.database = first_non_empty(
        args.database,
        from_env(file_values, "SQL_DATABASE", "MSSQL_DATABASE", "DB_DATABASE", "DATABASE"),
    )
    args.username = first_non_empty(
        args.username,
        from_env(file_values, "SQL_USERNAME", "MSSQL_USERNAME", "DB_USERNAME", "DB_USER", "USERNAME"),
    )
    args.password = first_non_empty(
        args.password,
        from_env(file_values, "SQL_PASSWORD", "MSSQL_PASSWORD", "DB_PASSWORD", "PASSWORD"),
    )
    args.driver = first_non_empty(
        args.driver,
        from_env(file_values, "SQL_DRIVER", "MSSQL_DRIVER", "DB_DRIVER"),
    )

    if args.encrypt is None:
        args.encrypt = first_non_empty(
            from_env(file_values, "SQL_ENCRYPT", "MSSQL_ENCRYPT", "DB_ENCRYPT"),
            "yes",
        )

    if not args.trust_server_certificate and "--trust-server-certificate" not in sys.argv:
        trust_value = from_env(
            file_values,
            "SQL_TRUST_SERVER_CERTIFICATE",
            "MSSQL_TRUST_SERVER_CERTIFICATE",
            "DB_TRUST_SERVER_CERTIFICATE",
            "TRUST_SERVER_CERTIFICATE",
        )
        args.trust_server_certificate = parse_bool(trust_value, default=False)


def resolve_driver(requested_driver: Optional[str]) -> str:
    if requested_driver:
        return requested_driver

    installed = pyodbc.drivers()
    sql_drivers = [name for name in installed if "sql server" in name.lower()]

    preferred_order = [
        "ODBC Driver 18 for SQL Server",
        "ODBC Driver 17 for SQL Server",
        "ODBC Driver 13 for SQL Server",
        "SQL Server Native Client 11.0",
        "SQL Server",
    ]

    for preferred in preferred_order:
        if preferred in sql_drivers:
            return preferred

    if sql_drivers:
        return sql_drivers[0]

    raise ValueError(
        "No SQL Server ODBC driver found. Install Microsoft ODBC Driver 18 for SQL Server, "
        "or pass --driver with an installed driver name."
    )


def build_engine(args: argparse.Namespace) -> sa.Engine:
    driver = resolve_driver(args.driver)
    query = {
        "driver": driver,
        "Encrypt": args.encrypt,
        "TrustServerCertificate": "yes" if args.trust_server_certificate else "no",
    }

    if args.username:
        if not args.password:
            raise ValueError("--password is required when --username is provided")
        url = URL.create(
            "mssql+pyodbc",
            username=args.username,
            password=args.password,
            host=args.server,
            database=args.database,
            query=query,
        )
    else:
        query["Trusted_Connection"] = "yes"
        url = URL.create(
            "mssql+pyodbc",
            host=args.server,
            database=args.database,
            query=query,
        )

    return sa.create_engine(url)


def read_sql_text(path: Path) -> str:
    for encoding in ("utf-8-sig", "cp1252"):
        try:
            return path.read_text(encoding=encoding)
        except UnicodeDecodeError:
            continue
    return path.read_text(encoding="latin-1")


def split_batches(sql_text: str) -> List[str]:
    batches: List[str] = []
    current_lines: List[str] = []

    for line in sql_text.splitlines(keepends=True):
        go_match = GO_PATTERN.match(line)
        if go_match:
            batch = "".join(current_lines).strip()
            if batch:
                repeat = int(go_match.group(1) or "1")
                for _ in range(repeat):
                    batches.append(batch)
            current_lines = []
            continue
        current_lines.append(line)

    tail = "".join(current_lines).strip()
    if tail:
        batches.append(tail)

    return batches


def parse_query_batches(sql_text: str) -> List[QueryBatch]:
    parsed: List[QueryBatch] = []

    for index, batch in enumerate(split_batches(sql_text), start=1):
        name_match = REPORT_NAME_PATTERN.search(batch)
        name = name_match.group(1).strip() if name_match else f"Query{index:02d}"
        sheet_name_match = SHEET_NAME_PATTERN.search(batch)
        sheet_name = sheet_name_match.group(1).strip() if sheet_name_match else None
        parsed.append(QueryBatch(name=name, sql=batch, sheet_name=sheet_name))

    return parsed


def sanitize_sheet_name(name: str) -> str:
    invalid = {"[", "]", ":", "*", "?", "/", "\\"}
    cleaned = "".join("_" if ch in invalid else ch for ch in name).strip()
    cleaned = cleaned.replace("'", "")
    if not cleaned:
        cleaned = "Sheet"
    return cleaned[:31]


def make_unique_sheet_name(name: str, used: set[str]) -> str:
    candidate = sanitize_sheet_name(name)
    if candidate not in used:
        used.add(candidate)
        return candidate

    base = candidate[:28]
    i = 1
    while True:
        next_name = f"{base}_{i}"
        if next_name not in used:
            used.add(next_name)
            return next_name
        i += 1


def write_markdown_summary(path: Path, generated_at: datetime, summary_rows: List[Tuple[str, int]]) -> None:
    lines = [
        "# Migration Review Summary",
        "",
        f"Generated: {generated_at.strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "| Section | Row Count |",
        "|---|---:|",
    ]
    for section, row_count in summary_rows:
        lines.append(f"| {section} | {row_count} |")

    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def add_action_reports(
    conn: sa.engine.Connection,
    used_sheet_names: set[str],
    summary_rows: List[Tuple[str, int]],
    failed_batches: List[Tuple[str, str]],
    writer: pd.ExcelWriter,
) -> None:
    """Add CustomerServiceAgreementPrices per-action detail sheets."""
    action_values_sql = sa.text(
        """
        SELECT
            DISTINCT [Action]
        FROM ModMigration.dbo.CustomerServiceAgreementPrices
        ORDER BY [Action]
        """
    )

    action_details_sql = sa.text(
        """
        SELECT
            DMAccount,
            ServiceCode,
            ServiceDescription,
            [Action]
        FROM ModMigration.dbo.CustomerServiceAgreementPrices
        WHERE (
            (:action_value IS NULL AND [Action] IS NULL)
            OR [Action] = :action_value
        )
        ORDER BY DMAccount, ServiceCode, ServiceDescription
        """
    )

    try:
        action_values_df = pd.read_sql_query(action_values_sql, conn)
    except Exception as ex:
        error_text = str(ex)
        failed_batches.append(("CSAP_ActionSheets", error_text))
        print(f"  CSAP_ActionSheets: FAILED -> {error_text}")
        return

    if action_values_df.empty:
        return

    for action_value in action_values_df["Action"].tolist():
        action_display = "NULL" if pd.isna(action_value) else str(action_value)
        raw_sheet_name = f"CSAP_Action_{action_display}"
        sheet_name = make_unique_sheet_name(raw_sheet_name, used_sheet_names)

        try:
            action_value_param = None if pd.isna(action_value) else str(action_value)
            detail_df = pd.read_sql_query(
                action_details_sql,
                conn,
                params={"action_value": action_value_param},
            )
            detail_df.to_excel(writer, sheet_name=sheet_name, index=False)
            summary_rows.append((sheet_name, len(detail_df)))
            print(f"  {sheet_name}: {len(detail_df)} rows")
        except Exception as ex:
            error_text = str(ex)
            failed_batches.append((raw_sheet_name, error_text))
            error_df = pd.DataFrame([{"Query": raw_sheet_name, "Error": error_text}])
            error_df.to_excel(writer, sheet_name=sheet_name, index=False)
            summary_rows.append((sheet_name, 0))
            print(f"  {sheet_name}: FAILED -> {error_text}")


def main() -> int:
    args = parse_args()
    resolve_connection_settings(args)

    if not args.server:
        print("Missing SQL server. Set --server or define SQL_SERVER in your .env file.", file=sys.stderr)
        return 2

    sql_file = Path(args.sql_file)
    if not sql_file.exists() or not sql_file.is_file():
        print(f"SQL file not found: {sql_file}", file=sys.stderr)
        return 2

    sql_text = read_sql_text(sql_file)
    batches = parse_query_batches(sql_text)
    if not batches:
        print(f"No query batches found in: {sql_file}", file=sys.stderr)
        return 2

    try:
        engine = build_engine(args)
    except ValueError as ex:
        print(str(ex), file=sys.stderr)
        return 2

    output_dir = Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = Path.cwd() / output_dir
    output_dir.mkdir(parents=True, exist_ok=True)

    run_stamp = datetime.now()
    suffix = run_stamp.strftime("%Y%m%d_%H%M%S")
    excel_path = output_dir / f"{args.output_prefix}_{suffix}.xlsx"
    markdown_path = output_dir / f"{args.output_prefix}_{suffix}.md"

    print(f"Running {len(batches)} review queries from: {sql_file}")
    print(f"Writing Excel report to: {excel_path}")

    used_sheet_names: set[str] = set()
    summary_rows: List[Tuple[str, int]] = []
    failed_batches: List[Tuple[str, str]] = []

    try:
        with engine.connect() as conn, pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
            for batch in batches:
                preferred_sheet_name = batch.sheet_name or batch.name
                sheet_name = make_unique_sheet_name(preferred_sheet_name, used_sheet_names)
                try:
                    df = pd.read_sql_query(sa.text(batch.sql), conn)
                    df.to_excel(writer, sheet_name=sheet_name, index=False)
                    summary_rows.append((sheet_name, len(df)))
                    print(f"  {sheet_name}: {len(df)} rows")
                except Exception as ex:
                    error_text = str(ex)
                    failed_batches.append((batch.name, error_text))
                    error_df = pd.DataFrame(
                        [
                            {
                                "Query": batch.name,
                                "Error": error_text,
                            }
                        ]
                    )
                    error_df.to_excel(writer, sheet_name=sheet_name, index=False)
                    summary_rows.append((sheet_name, 0))
                    print(f"  {sheet_name}: FAILED -> {error_text}")

            add_action_reports(
                conn=conn,
                used_sheet_names=used_sheet_names,
                summary_rows=summary_rows,
                failed_batches=failed_batches,
                writer=writer,
            )

            run_info = pd.DataFrame(
                [
                    {
                        "GeneratedAt": run_stamp.strftime("%Y-%m-%d %H:%M:%S"),
                        "Server": args.server,
                        "Database": args.database or "(default)",
                        "SQLFile": str(sql_file),
                        "SucceededQueries": len(batches) - len(failed_batches),
                        "FailedQueries": len(failed_batches),
                    }
                ]
            )
            run_info.to_excel(writer, sheet_name=make_unique_sheet_name("RunInfo", used_sheet_names), index=False)

            summary_df = pd.DataFrame(summary_rows, columns=["Section", "RowCount"])
            summary_df.to_excel(writer, sheet_name=make_unique_sheet_name("Summary", used_sheet_names), index=False)

            if failed_batches:
                failures_df = pd.DataFrame(failed_batches, columns=["Query", "Error"])
                failures_df.to_excel(
                    writer,
                    sheet_name=make_unique_sheet_name("Failures", used_sheet_names),
                    index=False,
                )
    except Exception as ex:
        print(f"Failed to generate review report: {ex}", file=sys.stderr)
        return 1
    finally:
        engine.dispose()

    write_markdown_summary(markdown_path, run_stamp, summary_rows)

    print("Review report completed.")
    print(f"- Excel: {excel_path}")
    print(f"- Markdown: {markdown_path}")
    if failed_batches:
        print("One or more queries failed. See the 'Failures' sheet for details.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
