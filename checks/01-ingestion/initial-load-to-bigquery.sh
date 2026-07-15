#!/usr/bin/env bash
#
# Acceptance check — Stage 01 · Load the initial extract into BigQuery
# ---------------------------------------------------------------------------
# Runs in GitHub Actions (workflow: .github/workflows/cloud-verify.yml) against
# YOUR OWN GCP project, authenticated by the service-account key you configured
# (see docs/CI_CLOUD_TESTING.md). It checks that your initial load actually did
# what the task asked: the dataset exists, every source table is present, the
# columns match, and the row counts match the source — exactly.
#
# It is SELF-VERIFYING: it reads the source files straight from the shared bucket
# via an ephemeral BigQuery external table and compares your loaded tables against
# them. No "expected" numbers are baked in here, so there is nothing to peek at and
# nothing to game — you pass by loading the data correctly.
#
# This file is owned by the tech lead (see CODEOWNERS). Don't edit it to make it
# pass; fix your load.
#
# Required environment (set for you by the workflow from your fork's secrets):
#   GCP_PROJECT_ID   your project id
#   GCP_DATASET      the dataset you loaded the initial extract into
# Optional overrides (sensible defaults; change only if the source layout differs):
#   SOURCE_BUCKET    default: internship-preperation
#   SOURCE_PREFIX    default: Dataset/initial
#   SOURCE_FORMAT    default: CSV
# ---------------------------------------------------------------------------
set -euo pipefail

: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is not set — see docs/CI_CLOUD_TESTING.md}"
: "${GCP_DATASET:?GCP_DATASET is not set — the dataset you loaded the initial extract into}"
SOURCE_BUCKET="${SOURCE_BUCKET:-internship-preperation}"
SOURCE_PREFIX="${SOURCE_PREFIX:-Dataset/initial}"
SOURCE_FORMAT="${SOURCE_FORMAT:-CSV}"

echo "Project:  ${GCP_PROJECT_ID}"
echo "Dataset:  ${GCP_DATASET}"
echo "Source:   gs://${SOURCE_BUCKET}/${SOURCE_PREFIX}/"
echo

# Return the single scalar value from a one-row/one-column query.
scalar() {
  bq query --project_id="${GCP_PROJECT_ID}" --nouse_legacy_sql \
    --format=csv --quiet "$1" | tail -n1 | tr -d '\r'
}

# 1. The dataset must exist.
if ! bq show --project_id="${GCP_PROJECT_ID}" "${GCP_PROJECT_ID}:${GCP_DATASET}" >/dev/null 2>&1; then
  echo "FAIL: dataset ${GCP_PROJECT_ID}:${GCP_DATASET} does not exist."
  exit 1
fi

# 2. Enumerate the tables that SHOULD be there, straight from the source bucket
#    (one sub-folder per table under the initial/ prefix).
mapfile -t TABLES < <(
  gcloud storage ls "gs://${SOURCE_BUCKET}/${SOURCE_PREFIX}/" \
    | sed -n 's#.*/\([^/]\{1,\}\)/$#\1#p' | sort -u
)
if [ "${#TABLES[@]}" -eq 0 ]; then
  echo "FAIL: found no source tables under gs://${SOURCE_BUCKET}/${SOURCE_PREFIX}/ — check the path."
  exit 1
fi
echo "Source has ${#TABLES[@]} tables to verify."
echo

fails=0
for t in "${TABLES[@]}"; do
  src_uri="gs://${SOURCE_BUCKET}/${SOURCE_PREFIX}/${t}/*"
  loaded="${GCP_PROJECT_ID}.${GCP_DATASET}.${t}"

  # 2a. Your table must exist.
  if ! bq show --project_id="${GCP_PROJECT_ID}" "${GCP_PROJECT_ID}:${GCP_DATASET}.${t}" >/dev/null 2>&1; then
    echo "FAIL[${t}]: table not found in dataset ${GCP_DATASET}."
    fails=$((fails + 1)); continue
  fi

  # 2b. Column sets must match (names, order-independent). Source columns = the header line
  #     of the first shard; loaded columns = the table schema. (|| true guards against the
  #     SIGPIPE from `head` closing the stream early under `set -o pipefail`.)
  first_shard="$(gcloud storage ls "${src_uri}" 2>/dev/null | head -n1 || true)"
  if [ -z "${first_shard}" ]; then
    echo "FAIL[${t}]: no source files at ${src_uri}."
    fails=$((fails + 1)); continue
  fi
  header="$(gcloud storage cat "${first_shard}" 2>/dev/null | head -n1 || true)"
  src_cols="$(printf '%s' "${header}" | tr -d '\r' | tr ',' '\n' | sort | paste -sd, -)"
  dst_cols="$(bq show --project_id="${GCP_PROJECT_ID}" --schema --format=prettyjson \
                "${GCP_PROJECT_ID}:${GCP_DATASET}.${t}" | jq -r '.[].name' | sort | paste -sd, -)"
  if [ "${src_cols}" != "${dst_cols}" ]; then
    echo "FAIL[${t}]: columns differ."
    echo "         source: ${src_cols}"
    echo "         loaded: ${dst_cols}"
    fails=$((fails + 1)); continue
  fi

  # 2c. Row counts must match the source exactly. Build an ephemeral external table over the
  #     shards with the header row explicitly skipped, so the count is deterministic rather
  #     than left to autodetect's header guess. Nothing is written to your dataset.
  def="$(mktemp)"
  if ! bq mkdef --autodetect --source_format="${SOURCE_FORMAT}" "${src_uri}" 2>/dev/null \
        | jq '.csvOptions.skipLeadingRows = "1"' >"${def}"; then
    echo "FAIL[${t}]: could not read source at ${src_uri}."
    fails=$((fails + 1)); rm -f "${def}"; continue
  fi
  src_count="$(bq query --project_id="${GCP_PROJECT_ID}" --nouse_legacy_sql --format=csv --quiet \
                 --external_table_definition="src::${def}" \
                 'SELECT COUNT(*) FROM src' | tail -n1 | tr -d '\r')"
  rm -f "${def}"
  dst_count="$(scalar "SELECT COUNT(*) FROM \`${loaded}\`")"
  if [ "${src_count}" != "${dst_count}" ]; then
    echo "FAIL[${t}]: row count ${dst_count} does not match source ${src_count}."
    fails=$((fails + 1)); continue
  fi

  echo "PASS[${t}]: ${dst_count} rows, ${dst_cols//,/ }" | cut -c1-160
done

echo
if [ "${fails}" -ne 0 ]; then
  echo "❌ initial-load check failed: ${fails} of ${#TABLES[@]} table(s) not correct."
  exit 1
fi
echo "✅ initial-load check passed: all ${#TABLES[@]} tables present, columns and row counts match the source."
