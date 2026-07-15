# Cloud testing with GitHub Actions

Your work is checked automatically. When you push a task under `templates/**`, a GitHub Actions
workflow (`cloud-verify`) runs that task's **acceptance check** against **your own GCP project** and
tells you, right on the pull request, whether it passed — dataset present, tables there, columns and
row counts correct, and so on. This page is the one-time setup that makes those checks able to reach
your project.

You do this in **your own fork**, with a **service account** you create on your **own project**. The
credential never leaves your fork's encrypted secrets, and its blast radius is only your free-tier
project.

> The other workflow, `ci`, runs lint + structure + local tests and needs no setup — it always runs.
> `cloud-verify` is the one that talks to GCP, so it needs the steps below.

---

## Before you start
- Your **own GCP project** (from the free-tier setup in the [Intern Guide](INTERN_ONBOARDING.md)).
- A **fork** of this repository (Fork ▸ your account). You push to your fork; checks run there.
- The `gcloud` CLI installed locally, or use Cloud Shell in the console.

---

## 1. Create a least-privilege service account
A *service account* (SA) is a non-human identity your CI uses to act on your project. Give it only
the roles the stage needs — never `Owner`.

```bash
gcloud config set project <YOUR_PROJECT_ID>

gcloud iam service-accounts create intern-ci \
  --display-name="Intern CI (GitHub Actions)"
```

Grant the roles for the stage you're working on (start minimal; add only if a check tells you it
can't do something):

| Stage | Roles to grant the SA |
|-------|-----------------------|
| 01 Ingestion | `roles/bigquery.jobUser`, `roles/bigquery.dataEditor`, `roles/storage.objectViewer` |
| 02 BigQuery | `roles/bigquery.jobUser`, `roles/bigquery.dataEditor` |
| 03 Dataplex | above + `roles/dataplex.editor`, `roles/datacatalog.viewer` (policy-tag/row-security work may need `roles/bigquery.dataOwner` on the dataset) |
| 06 Vertex | `roles/aiplatform.user`, `roles/storage.objectAdmin`, `roles/artifactregistry.writer` |

Example (Stage 01):
```bash
SA="intern-ci@<YOUR_PROJECT_ID>.iam.gserviceaccount.com"
for role in roles/bigquery.jobUser roles/bigquery.dataEditor roles/storage.objectViewer; do
  gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> \
    --member="serviceAccount:${SA}" --role="${role}"
done
```
> **Reading the shared source bucket.** `gs://internship-preperation/...` lives in the *tech lead's*
> project, so a role on **your** project grants no access to it. The tech lead grants your CI service
> account (or your project) read on that bucket separately — the checks read the source from there.
> If a check fails with a `403` on `gs://internship-preperation/...`, ask the tech lead to grant your
> CI service account `roles/storage.objectViewer` on the bucket.

> Stages 04 (Airflow), 05 (Dataflow), 07 (Looker) and 08 (custom viz) are checked locally, not by
> this workflow, so they don't need an SA. See `checks/README.md`.

---

## 2. Create and download a key
```bash
gcloud iam service-accounts keys create key.json \
  --iam-account="intern-ci@<YOUR_PROJECT_ID>.iam.gserviceaccount.com"
```
This writes `key.json`. **Treat it like a password.** Never commit it, never paste it in a task,
never share it. You'll put it into a GitHub secret next and then delete the local copy.

---

## 3. Add the secrets to your fork
In your fork: **Settings ▸ Secrets and variables ▸ Actions ▸ New repository secret**. Add:

| Secret name | Value |
|-------------|-------|
| `GCP_SA_KEY` | the **entire contents** of `key.json` |
| `GCP_PROJECT_ID` | your project id |
| `GCP_DATASET` | the dataset you load/build into (e.g. the one from Stage 02 · Dataset & tier design) |

Then delete the local key so it can't leak:
```bash
rm key.json
```

---

## 4. Push and watch it run
Commit your task work and push to your fork. Open the **Actions** tab → **cloud-verify**. It will:
1. detect which task folder you changed,
2. authenticate to your project with the SA,
3. run that task's check and report pass/fail.

You can also trigger it by hand: **Actions ▸ cloud-verify ▸ Run workflow**, and pass a task folder
like `templates/01-ingestion/initial-load-to-bigquery`.

If you haven't added the secrets yet, the workflow doesn't fail — it prints a note pointing back
here and skips.

---

## Security & teardown (read this)
The key is a **long-lived credential**. Keep it safe:
- **Only** ever in your fork's encrypted **Actions secrets**. Not in the repo, not in `docs/`, not in
  a script, not in chat.
- **Least privilege** — grant the table roles above, never `Owner`/`Editor` on the whole project.
- **Rotate/delete when done.** When you finish a stage (or if a key is ever exposed), delete it:
  ```bash
  gcloud iam service-accounts keys list \
    --iam-account="intern-ci@<YOUR_PROJECT_ID>.iam.gserviceaccount.com"
  gcloud iam service-accounts keys delete <KEY_ID> \
    --iam-account="intern-ci@<YOUR_PROJECT_ID>.iam.gserviceaccount.com"
  ```
- At the end of the program, delete the whole SA: `gcloud iam service-accounts delete <SA_EMAIL>`.

> **Why a key and not keyless?** Keyless auth (Workload Identity Federation) avoids a downloadable
> credential entirely and is the stronger option; we use a key here because it's the simplest to set
> up on a personal project. If your cohort moves to Workload Identity Federation later, only step 1–3
> change — the workflow already requests the `id-token` permission it needs.

---

## What the check actually tests
It enforces the **`## Output & expectations`** section of your task README — nothing more. For the
initial load, for example, it compares your loaded tables **directly against the source files** in
Cloud Storage (via a throwaway BigQuery external table), so it checks real correctness — every table
present, columns matching, row counts equal to the source — without any "answer key" hidden in the
repo. You pass by doing the task correctly. The check scripts live in `checks/` and are owned by the
tech lead; you don't edit them.
