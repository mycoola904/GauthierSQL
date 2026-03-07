#!/usr/bin/env python3
"""Run numbered SQL files from the ./sql folder against Microsoft SQL Server."""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

try:
    import pyodbc
except ImportError:
    print("Missing dependency: pyodbc. Install with: pip install pyodbc", file=sys.stderr)
    raise


GO_PATTERN = re.compile(r"^\s*GO(?:\s+(\d+))?\s*(?:--.*)?$", re.IGNORECASE)
LEADING_NUMBER_PATTERN = re.compile(r"^(\d+)")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Execute .sql scripts in numeric filename order against MSSQL."
    )
    parser.add_argument("--scripts-dir", default="sql\\build", help="Directory containing .sql files")
    parser.add_argument(
        "--env-file",
        default=".env",
        help="Path to .env file for connection settings",
    )
    parser.add_argument("--server", help="SQL Server name or host")
    parser.add_argument("--database", help="Default database to connect to")
    parser.add_argument(
        "--driver",
        help="ODBC driver (optional; auto-detected when omitted)",
    )
    parser.add_argument("--username", help="SQL login username (omit for Windows auth)")
    parser.add_argument("--password", help="SQL login password")
    parser.add_argument(
        "--encrypt",
        choices=["yes", "no"],
        default=None,
        help="ODBC Encrypt setting",
    )
    parser.add_argument(
        "--trust-server-certificate",
        action="store_true",
        help="Set TrustServerCertificate=yes",
    )
    parser.add_argument(
        "--autocommit",
        action="store_true",
        help="Enable connection autocommit",
    )
    parser.add_argument(
        "--continue-on-error",
        action="store_true",
        help="Continue to next file if a script fails",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show ordered files and batch counts without executing",
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


def parse_bool(value: str) -> bool:
    normalized = value.strip().lower()
    return normalized in {"1", "true", "yes", "y", "on"}


def resolve_connection_settings(args: argparse.Namespace) -> None:
    file_values = load_dotenv_file(Path(args.env_file))

    def from_env(*keys: str) -> Optional[str]:
        for key in keys:
            if key in os.environ and os.environ[key] != "":
                return os.environ[key]
            if key in file_values and file_values[key] != "":
                return file_values[key]
        return None

    # CLI values take precedence over environment values.
    args.server = first_non_empty(
        args.server,
        from_env("SQL_SERVER", "MSSQL_SERVER", "DB_SERVER", "SERVER"),
    )
    args.database = first_non_empty(
        args.database,
        from_env("SQL_DATABASE", "MSSQL_DATABASE", "DB_DATABASE", "DATABASE"),
    )
    args.username = first_non_empty(
        args.username,
        from_env("SQL_USERNAME", "MSSQL_USERNAME", "DB_USERNAME", "DB_USER", "USERNAME"),
    )
    args.password = first_non_empty(
        args.password,
        from_env("SQL_PASSWORD", "MSSQL_PASSWORD", "DB_PASSWORD", "PASSWORD"),
    )

    if args.encrypt is None:
        args.encrypt = first_non_empty(
            from_env("SQL_ENCRYPT", "MSSQL_ENCRYPT", "DB_ENCRYPT"),
            "yes",
        )

    # Respect explicit CLI flag, otherwise allow env var to enable trust mode.
    if not args.trust_server_certificate and "--trust-server-certificate" not in sys.argv:
        trust_value = from_env(
            "SQL_TRUST_SERVER_CERTIFICATE",
            "MSSQL_TRUST_SERVER_CERTIFICATE",
            "DB_TRUST_SERVER_CERTIFICATE",
            "TRUST_SERVER_CERTIFICATE",
        )
        if trust_value is not None:
            args.trust_server_certificate = parse_bool(trust_value)


def sql_file_sort_key(path: Path) -> Tuple[int, int, str]:
    match = LEADING_NUMBER_PATTERN.match(path.name)
    if match:
        return (0, int(match.group(1)), path.name.lower())
    # Non-numbered files are pushed to the end and sorted alphabetically.
    return (1, 10**9, path.name.lower())


def get_sql_files(scripts_dir: Path) -> List[Path]:
    files = [p for p in scripts_dir.iterdir() if p.is_file() and p.suffix.lower() == ".sql"]
    return sorted(files, key=sql_file_sort_key)


def read_sql_text(path: Path) -> str:
    for encoding in ("utf-8-sig", "cp1252"):
        try:
            return path.read_text(encoding=encoding)
        except UnicodeDecodeError:
            continue
    # Final fallback to avoid hard-failing on mixed encodings.
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


def build_connection_string(args: argparse.Namespace) -> str:
    driver = resolve_driver(args.driver)

    parts = [
        f"DRIVER={{{driver}}}",
        f"SERVER={args.server}",
        f"Encrypt={args.encrypt}",
    ]

    if args.database:
        parts.append(f"DATABASE={args.database}")

    if args.username:
        if not args.password:
            raise ValueError("--password is required when --username is provided")
        parts.append(f"UID={args.username}")
        parts.append(f"PWD={args.password}")
    else:
        parts.append("Trusted_Connection=yes")

    if args.trust_server_certificate:
        parts.append("TrustServerCertificate=yes")

    return ";".join(parts)


def strip_database_from_connection_string(connection_string: str) -> str:
    parts = []
    for part in connection_string.split(";"):
        if part.strip().upper().startswith("DATABASE="):
            continue
        if part.strip() == "":
            continue
        parts.append(part)
    return ";".join(parts)


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


def execute_file(cursor: "pyodbc.Cursor", sql_file: Path) -> int:
    sql_text = read_sql_text(sql_file)
    batches = split_batches(sql_text)

    for i, batch in enumerate(batches, start=1):
        cursor.execute(batch)
        print(f"  Batch {i}/{len(batches)} succeeded")

    return len(batches)


def main() -> int:
    args = parse_args()
    resolve_connection_settings(args)

    if not args.server:
        print(
            "Missing SQL server. Set --server or define SQL_SERVER in your .env file.",
            file=sys.stderr,
        )
        return 2

    scripts_dir = Path(args.scripts_dir)

    if not scripts_dir.exists() or not scripts_dir.is_dir():
        print(f"Scripts directory not found: {scripts_dir}", file=sys.stderr)
        return 2

    sql_files = get_sql_files(scripts_dir)
    if not sql_files:
        print(f"No .sql files found in: {scripts_dir}")
        return 0

    for idx, file in enumerate(sql_files, start=1):
        print(f"{idx:02d}. {file.name}")

    if args.dry_run:
        print("\nDry run only: no SQL executed.")
        for file in sql_files:
            batch_count = len(split_batches(read_sql_text(file)))
            print(f"{file.name}: {batch_count} batch(es)")
        return 0

    try:
        connection_string = build_connection_string(args)
    except ValueError as ex:
        print(str(ex), file=sys.stderr)
        return 2

    succeeded = 0
    failed = 0

    try:
        conn = pyodbc.connect(connection_string, autocommit=args.autocommit)
    except pyodbc.Error as ex:
        print(f"Connection failed: {ex}", file=sys.stderr)
        text = str(ex)
        if "certificate chain was issued by an authority that is not trusted" in text.lower():
            print(
                "TLS certificate validation failed. For non-production/dev environments, "
                "set SQL_TRUST_SERVER_CERTIFICATE=true in .env or pass --trust-server-certificate.",
                file=sys.stderr,
            )
        if "(4060)" in text and args.database:
            print(
                f"Configured database '{args.database}' is not accessible to this login. "
                "Retrying connection without DATABASE=...",
                file=sys.stderr,
            )
            try:
                retry_connection_string = strip_database_from_connection_string(connection_string)
                conn = pyodbc.connect(retry_connection_string, autocommit=args.autocommit)
            except pyodbc.Error:
                print(
                    "Retry without database also failed. Verify SQL_DATABASE in .env and user permissions.",
                    file=sys.stderr,
                )
                return 1
        else:
            return 1

    with conn:
        cursor = conn.cursor()

        for file in sql_files:
            print(f"\nRunning: {file.name}")
            try:
                batch_count = execute_file(cursor, file)
                if not args.autocommit:
                    conn.commit()
                succeeded += 1
                print(f"Completed: {file.name} ({batch_count} batch(es))")
            except pyodbc.Error as ex:
                failed += 1
                if not args.autocommit:
                    conn.rollback()
                print(f"FAILED: {file.name}")
                print(f"Reason: {ex}", file=sys.stderr)
                if not args.continue_on_error:
                    print("Stopping at first error.", file=sys.stderr)
                    break

    print(f"\nSummary: {succeeded} succeeded, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
