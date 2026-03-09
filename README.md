# Gauthier SQL Migration Toolkit

Utilities for running SQL migration scripts, validating migration results, and exporting data snapshots to Excel.

## What Is In This Repo

- `run_sql_scripts.py`: Executes SQL files in `sql/build` in numeric order (`1...22`) and splits batches on `GO`.
- `review_migration.py`: Runs review queries from `sql/review/review_customers_report.sql` and generates:
  - Excel workbook with one sheet per report
  - Markdown summary with section row counts
- `extractdata.py`: Exports selected migration tables to an Excel workbook.
- `sql/build/`: Migration/build scripts.
- `sql/review/`: Review/report SQL.
- `excel/review/`: Generated review outputs.

## Prerequisites

- Windows (or compatible SQL Server ODBC environment)
- Python 3.10+
- Microsoft SQL Server ODBC Driver installed (recommended: ODBC Driver 18)
- Access to source/target SQL Server databases

## Setup

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Create a `.env` file in the repo root.

## .env Example

```env
# Required for run_sql_scripts.py and review_migration.py
SQL_SERVER=YOUR_SERVER
SQL_DATABASE=ModMigration
SQL_DRIVER=ODBC Driver 18 for SQL Server
SQL_ENCRYPT=yes
SQL_TRUST_SERVER_CERTIFICATE=true

# Optional SQL auth (omit for Windows auth in run/review scripts)
SQL_USERNAME=YOUR_SQL_USER
SQL_PASSWORD=YOUR_SQL_PASSWORD

# Optional extractdata.py settings
EXCEL_PATH=output
EXCEL_FILE_NAME=extract.xlsx
PROJECT_NAME=Gauthier
```

Notes:
- `run_sql_scripts.py` and `review_migration.py` support Windows auth when `SQL_USERNAME`/`SQL_PASSWORD` are omitted.
- `extractdata.py` currently expects `SQL_USERNAME` and `SQL_PASSWORD`.

## Usage

### 1. Run migration/build SQL files

```powershell
python run_sql_scripts.py
```

Common options:

```powershell
python run_sql_scripts.py --dry-run
python run_sql_scripts.py --continue-on-error
python run_sql_scripts.py --scripts-dir "sql\build"
python run_sql_scripts.py --database ModMigration
```

### 2. Generate migration review report (Excel + Markdown)

```powershell
python review_migration.py
```

Common options:

```powershell
python review_migration.py --sql-file "sql\review\review_customers_report.sql"
python review_migration.py --output-dir "excel\review"
python review_migration.py --output-prefix "customer_migration_review"
```

Output files are timestamped, for example:
- `excel/review/customer_migration_review_20260308_151353.xlsx`
- `excel/review/customer_migration_review_20260308_151353.md`

### 3. Export migration tables to Excel snapshot

```powershell
python extractdata.py
```

## Review SQL Format

`review_migration.py` parses report batches from the SQL file using `GO` separators.

Use metadata comments to control report naming:

```sql
-- report: MyCheck
-- sheet: MyExactSheetName
SELECT ...
GO
```

- `-- report:` sets the logical report name.
- `-- sheet:` optionally forces the exact Excel sheet name.

## Troubleshooting

- TLS/certificate errors:
  - Set `SQL_TRUST_SERVER_CERTIFICATE=true` in `.env` or pass `--trust-server-certificate`.
- Login/database access errors:
  - Verify `SQL_SERVER`, `SQL_DATABASE`, credentials, and permissions.
- Missing driver errors:
  - Install Microsoft ODBC Driver 18 for SQL Server, or set `SQL_DRIVER` to an installed driver.

## Typical Workflow

1. Run build scripts with `run_sql_scripts.py`.
2. Generate validation outputs with `review_migration.py`.
3. Export detailed table snapshots with `extractdata.py` when needed.
