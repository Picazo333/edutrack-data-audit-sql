#!/usr/bin/env bash
# Recrea la base desde edutrack.sql y corre la auditoría plana Q1–Q12.
# Las consultas de esa auditoría están en 019/queries.sql (el archivo no cambia).
# Uso, desde la raíz del repo o desde cualquier sitio:
#   ./scripts/recreate_and_run.sh
# Variable opcional: EDUTRACK_DB (por defecto: edutrack)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DB="${EDUTRACK_DB:-edutrack}"
EVIDENCE="$ROOT/evidence/psql"
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

python3 - "$ROOT/019/queries.sql" <<'PY'
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
if re.search(r"(?m)^\\", text):
    sys.exit("queries.sql contiene un metacomando psql; en Supabase fallaría")

if re.search(
    r"(?i)\b(insert\s+into|update|delete\s+from|alter\s+table|drop\s+table|truncate(?:\s+table)?)\s+(students|courses)\b",
    text,
):
    sys.exit("queries.sql modifica students o courses")

markers = [text.index(f"-- Q{i}:") for i in range(1, 13)]
if markers != sorted(markers):
    sys.exit("Q1–Q12 no están en orden")

update_at = text.index("UPDATE enrollments")
delete_at = text.index("DELETE FROM enrollments")
q9_at = text.index("-- Q9:")
if not (update_at < delete_at < q9_at):
    sys.exit("Q9 no queda después de las correcciones")

if text.rfind("WHERE instructor IS NULL", 0, update_at) < 0:
    sys.exit("falta el SELECT de verificación antes del UPDATE")
if text.rfind("LIKE '%@test.com'", 0, delete_at) < 0:
    sys.exit("falta el SELECT de verificación antes del DELETE")

for token in ("GROUP BY", "HAVING", "Pending assignment", "INSERT INTO enrollments"):
    if token not in text:
        sys.exit(f"falta {token}")
print("comprobación estática de queries.sql: ok")
PY

OFFICIAL_SHA="faebf83f72bbf95d7ef55aad78f36fc9168891c36e8994eeb4a65629086e3387"
ACTUAL_SHA="$(sha256sum "$ROOT/edutrack.sql" | awk '{print $1}')"
if [[ "$ACTUAL_SHA" != "$OFFICIAL_SHA" ]]; then
  echo "edutrack.sql no coincide con el asset oficial" >&2
  echo "esperado $OFFICIAL_SHA" >&2
  echo "actual   $ACTUAL_SHA" >&2
  exit 1
fi

run_dropdb --if-exists "$DB"
run_createdb "$DB"

{
  echo "# carga edutrack.sql"
  echo "sha256=$ACTUAL_SHA"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/edutrack.sql"
} | tee "$EVIDENCE/01_load.txt"

{
  echo "# verificación de la importación"
  "${PSQL[@]}" -d "$DB" -c '\dt'
  "${PSQL[@]}" -d "$DB" -f "$ROOT/scripts/verify_import.sql"
} | tee "$EVIDENCE/02_import_check.txt"

hash_of() {
  local table="$1"
  "${PSQL[@]}" -d "$DB" -At -c "SELECT md5(COALESCE(string_agg(x::text, E'\n' ORDER BY id), '')) FROM ${table} AS x;"
}

STUDENTS_BEFORE="$("${PSQL[@]}" -d "$DB" -At -c 'SELECT COUNT(*) FROM students;')"
COURSES_BEFORE="$("${PSQL[@]}" -d "$DB" -At -c 'SELECT COUNT(*) FROM courses;')"
STUDENTS_HASH_BEFORE="$(hash_of students)"
COURSES_HASH_BEFORE="$(hash_of courses)"

{
  echo "# snapshot ANTES de Q6–Q8"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/scripts/snapshot_health.sql"
} | tee "$EVIDENCE/03_snapshot_before.txt"

{
  echo "# filtros Q1 Q2 Q4 Q5 ANTES de las correcciones"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/scripts/read_filters.sql"
} | tee "$EVIDENCE/03b_filters_before.txt"

{
  echo "# queries.sql Q1–Q12"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/019/queries.sql"
} | tee "$EVIDENCE/04_queries.txt"

{
  echo "# snapshot DESPUÉS de Q6–Q8"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/scripts/snapshot_health.sql"
} | tee "$EVIDENCE/05_snapshot_after.txt"

{
  echo "# filtros Q1 Q2 Q4 Q5 DESPUÉS de las correcciones"
  "${PSQL[@]}" -d "$DB" -f "$ROOT/scripts/read_filters.sql"
} | tee "$EVIDENCE/05b_filters_after.txt"

{
  echo "# aserciones"
  "${PSQL[@]}" -d "$DB" \
    -v "students_before=${STUDENTS_BEFORE}" \
    -v "courses_before=${COURSES_BEFORE}" \
    -f "$ROOT/scripts/assert_after.sql"
} | tee "$EVIDENCE/06_assert.txt"

STUDENTS_HASH_AFTER="$(hash_of students)"
COURSES_HASH_AFTER="$(hash_of courses)"
if [[ "$STUDENTS_HASH_BEFORE" != "$STUDENTS_HASH_AFTER" ]]; then
  echo "cambió el contenido de students" >&2
  exit 1
fi
if [[ "$COURSES_HASH_BEFORE" != "$COURSES_HASH_AFTER" ]]; then
  echo "cambió el contenido de courses" >&2
  exit 1
fi

PG_VERSION="$("${PSQL[@]}" -d "$DB" -At -c 'SHOW server_version;')"
{
  echo "finished_at=$(date -Iseconds)"
  echo "database=$DB"
  echo "postgres=$PG_VERSION"
  echo "edutrack_sha256=$ACTUAL_SHA"
  echo "queries_sha256=$(sha256sum "$ROOT/019/queries.sql" | awk '{print $1}')"
  echo "students_before=$STUDENTS_BEFORE"
  echo "courses_before=$COURSES_BEFORE"
  echo "students_hash=$STUDENTS_HASH_AFTER"
  echo "courses_hash=$COURSES_HASH_AFTER"
  echo "assert=pass"
} | tee "$EVIDENCE/07_run_stamp.txt"

echo "auditoría reproducible: ok ($EVIDENCE)"
