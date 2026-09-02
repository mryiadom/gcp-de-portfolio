# gcp-de-portfolio

Working repo for the GCP Data Engineer roadmap — Foundations to Capstone (33 weeks, 6 phases).
Open `gcp-de-tracker.html` in a browser to track progress; it holds the full week-by-week plan.

## Structure

Folders are added incrementally as the plan calls for them, one week at a time — see
`gcp-de-tracker.html` for the exact file each day produces. Current:

- `scripts/` — shell scripts from Phase 0 (Week 1, The Command Line)

## Conventions

- Python: `snake_case.py`. Notebooks: two-digit prefix (`01_cleaning.ipynb`).
- SQL: `snake_case.sql`, one file per model/question.
- Terraform: `main.tf`, `variables.tf`, `outputs.tf`, `iam.tf`.
- Commits: imperative mood, one logical change (`add rolling volatility to stats notebook`).
- Secrets: never committed — environment variables locally, Secret Manager in GCP.
