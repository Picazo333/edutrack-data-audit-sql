#!/usr/bin/env bash
# Recrea la base desde edutrack_v2.sql y corre las 10 consultas con JOIN.
# Uso, desde la raíz del repo o desde cualquier sitio:
#   ./scripts/recreate_and_run_v2.sh
# Variable opcional: EDUTRACK_V2_DB (por defecto: edutrack_v2)
# No toca la base `edutrack` de la auditoría plana.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DB="${EDUTRACK_V2_DB:-edutrack_v2}"
EVIDENCE="$ROOT/evidence/psql-v2"
mkdir -p "$EVIDENCE"

if psql -d postgres -v ON_ERROR_STOP=1 -c 'SELECT 1' >/dev/null 2>&1; then
  run_psql() { psql "$@"; }
  run_dropdb() { dropdb "$@"; }
  run_createdb() { createdb "$@"; }
else
  run_psql() { sudo -u postgres psql "$@"; }
  run_dropdb() { sudo -u postgres dropdb "$@"; }
  run_createdb() { sudo -u postgres createdb "$@"; }
fi

PSQL=(run_psql -v ON_ERROR_STOP=1 -P pager=off)

(cd "$ROOT/019" && sha256sum -c SHA256SUMS)

python3 - "$ROOT/queries.sql" <<'PY'
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
if re.search(r"(?m)^\\", text):
    sys.exit("queries.sql contiene un metacomando psql; en Supabase fallaría")

if re.search(
    r"(?i)\b(insert\s+into|update|delete\s+from|alter\s+table|drop\s+table|truncate(?:\s+table)?|create\s+table)\b",
    text,
):
    sys.exit("queries.sql no es solo lectura")

if re.search(r"(?i)\b(with|exists|lateral)\b", text):
    sys.exit("queries.sql usa CTE, EXISTS o LATERAL")

if re.search(r"(?is)\(\s*select\b", text):
    sys.exit("queries.sql contiene una subconsulta")

parts = re.split(r"(?m)^-- Q(\d+):", text)
if parts[0].count("SET datestyle") != 1:
    sys.exit("falta SET datestyle")

numbers = parts[1::2]
bodies = parts[2::2]
if numbers != [str(i) for i in range(1, 11)]:
    sys.exit(f"se esperaban Q1–Q10 en orden, hay {numbers}")

for number, body in zip(numbers, bodies):
    if re.search(r"(?i)\bjoin\b", body) is None:
        sys.exit(f"Q{number} no tiene JOIN")

for number in ("1", "2", "3"):
    body = bodies[int(number) - 1]
    if re.search(r"(?i)\binner\s+join\b", body) is None:
        sys.exit(f"Q{number} no tiene INNER JOIN")

for number in ("4", "5", "9", "10"):
    body = bodies[int(number) - 1]
    if re.search(r"(?i)\bleft\s+join\b", body) is None or "IS NULL" not in body:
        sys.exit(f"Q{number} no es un LEFT JOIN que se quede con las filas sin pareja")

q6 = bodies[5]
if "GROUP BY" not in q6 or "HAVING" not in q6:
    sys.exit("Q6 no filtra el agregado con GROUP BY y HAVING")

q7 = bodies[6]
if "monthly_fee" not in q7 or "monthly_fee_paid" in q7:
    sys.exit("Q7 tiene que sumar courses.monthly_fee y no el pago histórico")
if "GROUP BY" not in q7:
    sys.exit("Q7 no agrupa")

q8 = bodies[7]
if "COUNT(DISTINCT e.student_id)" not in q8 or "GROUP BY" not in q8:
    sys.exit("Q8 no cuenta estudiantes distintos por instructor")

print("comprobación estática de queries.sql: ok")
PY

OFFICIAL_SHA="091f6fa2948d0847cfe06937b2d24572a0afa292fbd19412764c220d39e17cb0"
ACTUAL_SHA="$(sha256sum "$ROOT/edutrack_v2.sql" | awk '{print $1}')"
if [[ "$ACTUAL_SHA" != "$OFFICIAL_SHA" ]]; then
  echo "edutrack_v2.sql no coincide con el asset oficial" >&2
  echo "esperado $OFFICIAL_SHA" >&2
  echo "actual   $ACTUAL_SHA" >&2
  exit 1
fi

run_dropdb --if-exists "$DB"
run_createdb "$DB"

{
  echo "# carga edutrack_v2.sql"
  echo "sha256=$ACTUAL_SHA"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/edutrack_v2.sql"
} | tee "$EVIDENCE/01_load.txt"

{
  echo "# verificación de la importación"
  "${PSQL[@]}" -d "$DB" -c '\dt'
  "${PSQL[@]}" -d "$DB" -a -f "$ROOT/scripts/v2/verify_import.sql"
} | tee "$EVIDENCE/02_import_check.txt"

{
  echo "# queries.sql Q1–Q10"
  "${PSQL[@]}" -d "$DB" -a -f "$ROOT/queries.sql"
} | tee "$EVIDENCE/03_queries.txt"

{
  echo "# suite de integridad referencial"
  "${PSQL[@]}" -d "$DB" -a -f "$ROOT/scripts/v2/integrity.sql"
} | tee "$EVIDENCE/04_integrity.txt"

{
  echo "# aserciones"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/scripts/v2/assert_v2.sql"
} | tee "$EVIDENCE/05_assert.txt"

python3 - "$EVIDENCE/03_queries.txt" "$ROOT/analysis_report.md" "$ROOT/diagram.png" <<'PY'
import re
import sys
from pathlib import Path

output = Path(sys.argv[1]).read_text(encoding="utf-8")
report = Path(sys.argv[2]).read_text(encoding="utf-8")
png = Path(sys.argv[3]).read_bytes()

if png[:8] != b"\x89PNG\r\n\x1a\n":
    sys.exit("diagram.png no es un PNG")

if re.search(r"(?m)^ERROR:", output):
    sys.exit("la salida de las consultas contiene ERROR")

parts = re.split(r"(?m)^-- Q(\d+):", output)
numbers = parts[1::2]
bodies = parts[2::2]
if numbers != [str(i) for i in range(1, 11)]:
    sys.exit(f"la salida no trae Q1–Q10, hay {numbers}")

expected_rows = {
    "1": 16,
    "2": 6,
    "3": 4,
    "4": 1,
    "5": 1,
    "6": 7,
    "7": 4,
    "8": 4,
    "9": 0,
    "10": 0,
}

for number, body in zip(numbers, bodies):
    found = re.findall(r"\((\d+) row", body)
    if len(found) != 1:
        sys.exit(f"Q{number}: se esperaba un solo resultado, hay {found}")
    got = int(found[0])
    if got != expected_rows[number]:
        sys.exit(f"Q{number}: {got} filas, se esperaban {expected_rows[number]}")

checks = {
    "1": ["Emily Watson", "Intro to Python", "INNER JOIN"],
    "2": ["Priya Sharma", "Digital Marketing 101", "passed = TRUE"],
    "3": ["Marta López", "66.1428571428571429", "Pending assignment"],
    "4": ["Giulia Romano", "LEFT JOIN", "IS NULL"],
    "5": ["Email Campaigns", "19.99", "LEFT JOIN"],
    "6": ["HAVING", "Emily Watson", "Lucia Fernandes"],
    "7": ["409.93", "179.97", "169.96", "59.98", "monthly_fee"],
    "8": ["COUNT(DISTINCT e.student_id)", "Marta López"],
    "9": ["(0 rows)", "LEFT JOIN", "student_id"],
    "10": ["(0 rows)", "LEFT JOIN", "course_id"],
}
for number, needles in checks.items():
    body = bodies[int(number) - 1]
    for needle in needles:
        if needle not in body:
            sys.exit(f"Q{number} no contiene {needle!r}")

if "Giulia Romano" in bodies[0] or "Email Campaigns" in bodies[0]:
    sys.exit("Q1 devolvió una fila que el INNER JOIN no debería traer")
if "Lucia Fernandes" in bodies[1] or "Giulia Romano" in bodies[1]:
    sys.exit("Q2 incluye a alguien sin curso aprobado")
if bodies[6].find("Programming") > bodies[6].find("Data"):
    sys.exit("Q7 no deja Programming como primera categoría")
if "monthly_fee_paid" in bodies[6]:
    sys.exit("Q7 menciona el pago histórico")

for needle in (
    "Giulia Romano",
    "Email Campaigns",
    "409.93",
    "179.97",
    "169.96",
    "59.98",
    "66.1428571428571429",
    "0.00000000000000000000",
    "Marta López",
    "Integridad referencial",
    "diagram.png",
    "student_id",
    "0 filas",
):
    if needle not in report:
        sys.exit(f"analysis_report.md no contiene {needle!r}")

print("comprobación de resultados e informe: ok")
PY

PG_VERSION="$("${PSQL[@]}" -d "$DB" -At -c 'SHOW server_version;')"
{
  echo "finished_at=$(date -Iseconds)"
  echo "database=$DB"
  echo "postgres=$PG_VERSION"
  echo "edutrack_v2_sha256=$ACTUAL_SHA"
  echo "queries_sha256=$(sha256sum "$ROOT/queries.sql" | awk '{print $1}')"
  echo "orphan_student_id=0"
  echo "orphan_course_id=0"
  echo "assert=pass"
} | tee "$EVIDENCE/06_run_stamp.txt"

echo "auditoría v2 reproducible: ok ($EVIDENCE)"
