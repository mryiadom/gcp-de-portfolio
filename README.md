# GCP Data Engineering Portfolio — Finance Track

Production-shaped data engineering on Google Cloud, built from finance and markets data.

## About

I'm Ronald, a Junior Data Engineer working day-to-day in SQL, Python, BigQuery and Dataform. This repo is the index for a structured 33-week deepening of that — Cloud Storage, BigQuery, dbt, Terraform, Airflow and Kafka — through three progressively larger projects.

Every week produces a committed artefact. Small components accumulate into three major projects, so nothing here is throwaway practice — the utility module written in Week 1 of Core Skills is imported by the capstone at the end.

## Why GCP

Built on Google Cloud because I use it daily — a portfolio that finishes beats one that gets abandoned, and it compounds with my day job instead of competing with it for the same evenings. The trade-off: my CV already says GCP, so this proves less that's new than a second-cloud build would.

The answer is the portable spine. SQL, dbt, Airflow, Kafka, Docker, Terraform, pytest, dimensional modelling and idempotency aren't cloud skills — they're roughly two-thirds of this plan and they move anywhere. Three things keep that honest rather than claimed: Airflow and Kafka run in Docker rather than as managed services, one week runs the same dbt project against **Snowflake**, and the Terraform bucket module is written for both GCS and S3.

## Projects

| # | Project | Stack | Status |
|---|---------|-------|--------|
| 1 | **Equity Markets Analytics** — public equities → Cloud Storage → BigQuery (via a Python `WarehouseClient` class) → pandas → Looker Studio → a written insight | Python, Cloud Storage, BigQuery, Looker Studio | Planned |
| 2 | **Market Data ELT Pipeline** — markets API → Cloud Storage → BigQuery → dbt star schema → Looker Studio, fully provisioned with Terraform | dbt, BigQuery, Terraform, Docker, pytest | Planned |
| 3 | **Trading-Data Platform** — capstone. Adds a Kafka streaming path (simulated ticks), Airflow orchestration, least-privilege IAM, data-quality checks with alerting, and CI/CD | Kafka, Airflow, IAM, Great Expectations, GitHub Actions | Planned |

Each project is documented in this repo with its own write-up and findings. Mini-projects across every week feed into them — a trade-utils module, a SQL query library, a cleaning notebook, a warehouse client class, a dbt project, a Terraform stack, a packaged ingestion module with retries and tests.

## Engineering standards

Applied across the repo from Core Skills onward:

- **Idempotent loads.** Re-running a pipeline must not duplicate data — proven by running the load twice, not assumed.
- **Infrastructure as code.** Terraform, not console clicks. The stack is destroyed and rebuilt on demand.
- **Tested transforms.** dbt tests on uniqueness, nullability and business rules; Great Expectations for the checks dbt can't express.
- **No secrets, ever.** Environment variables locally, Secret Manager in Google Cloud, and git history checked as well as the working tree.
- **Least privilege.** One service account per service, tested to confirm it fails when it should.
- **CI on every pull request.** pytest, `dbt build`, ruff and sqlfluff, with merges gated on green checks.

## Cost control

Built to stay inside free tiers: BigQuery gives 1 TiB of queries and 10 GB of storage free every month against a dataset of roughly 200 MB, and Airflow, Kafka, dbt Core and Great Expectations all run locally under Docker rather than as paid managed services. A Cloud Billing budget alert has been set from day one, with a £5 ceiling generous enough that if it ever fires, something is wrong rather than expensive. The one paid item — the GCP Professional Data Engineer exam — is optional, at the end, and also satisfies the certification line in my workplace development plan.

## Roadmap

A 33-week plan in six phases:

| Phase | Weeks | Focus |
|---|---|---|
| 0 | 1–6 | Foundations — shell, git, Python environments, data representation, HTTP, query execution |
| 1 | 7–11 | Core skills — Python, SQL, pandas, advanced SQL, OOP |
| 2 | 12–17 | GCP foundations — Cloud Storage, BigQuery, statistics, BI — and **Project 1** |
| 3 | 18–26 | DE core — modelling, dbt, cost tuning, Terraform, Docker, production Python — and **Project 2** |
| 4 | 27–31 | Production systems — Airflow in depth, IAM, data quality, CI/CD, Kafka |
| 5 | 32–33 | **Capstone** and interview preparation |

Applications begin at Week 17, in parallel with Phases 3–5, rather than at the end.

## Progress

Full interactive tracker: [gcp-de-tracker](https://mryiadom.github.io/gcp-de-portfolio/gcp-de-tracker.html).

**Phase 0 — Foundations (Weeks 1–6)**
- [ ] Week 1 — The Command Line
- [ ] Week 2 — Git and Code Review
- [ ] Week 3 — Python Environments and Tooling
- [ ] Week 4 — How Data Is Actually Represented
- [ ] Week 5 — How the Internet Moves Data
- [ ] Week 6 — How a Query Actually Runs

**Phase 1 — Core Skills (Weeks 7–11)**
- [x] Week 7 — Python Fundamentals
- [ ] Week 8 — SQL Fundamentals
- [ ] Week 9 — Pandas Fundamentals
- [ ] Week 10 — Advanced SQL: Window Functions, CTEs, Optimisation
- [ ] Week 11 — Python OOP for Data Engineers

**Phase 2 — GCP Foundations & First Project (Weeks 12–17)**
- [ ] Week 12 — Cloud Storage & BigQuery: Building the Lake
- [ ] Week 13 — Statistics & Maths for a Quant-Track Engineer
- [ ] Week 14 — Visualisation Principles & BI (Looker Studio)
- [ ] Week 15 — Market Data Domain Essentials
- [ ] Week 16 — Major Project 1: Equity Markets Analytics
- [ ] Week 17 — Project 1 Polish + Start Applying

**Phase 3 — Data Engineering Core (Weeks 18–26)**
- [ ] Week 18 — Data Modelling & Normalisation
- [ ] Week 19 — Dimensional Modelling (Kimball) + Snowflake Awareness
- [ ] Week 20 — ETL vs ELT & Pipeline Architecture
- [ ] Week 21 — dbt on BigQuery
- [ ] Week 22 — BigQuery Performance and Cost
- [ ] Week 23 — Infrastructure as Code (Terraform)
- [ ] Week 24 — Docker & Containerisation
- [ ] Week 25 — Production Python for Data Engineering
- [ ] Week 26 — Major Project 2: Market Data ELT Pipeline

**Phase 4 — Production Systems (Weeks 27–31)**
- [ ] Week 27 — Orchestration I: Airflow Foundations
- [ ] Week 28 — Orchestration II: Airflow in Production
- [ ] Week 29 — Security & IAM for Data Platforms
- [ ] Week 30 — Data Quality, Testing & CI/CD
- [ ] Week 31 — Streaming with Kafka

**Phase 5 — Capstone & Job Hunt (Weeks 32–33)**
- [ ] Week 32 — Major Project 3: Trading-Data Platform (Build)
- [ ] Week 33 — Capstone Polish, CV & Interview Prep

## Contact

[LinkedIn](https://www.linkedin.com/in/ronald-yiadom-853622200/) · rwyiadom@gmail.com
