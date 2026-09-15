# data-products

dbt projects — the modelling layer that turns raw ingested data into something worth
querying. One folder per project.

## The two sample projects

These come from the platform's own pipelines. Use either as a starting point for your
own project:

| Project | What it builds | Reads | On the platform |
|---|---|---|---|
| [`asset_transactions`](asset_transactions/) | Fixed-asset transactions from the SAP asset tables | `synsap_finance_raw` | Runs daily in the platform pipeline |
| [`sub_ledger`](sub_ledger/) | SAP open/cleared item indexes (BSID, BSAD, BSIK, BSAK) derived from BSEG | `synsap_finance_raw` | In the platform pipeline, schedule currently paused |

They are written for dbt-spark, which the platform itself uses. **Your projects run on
dbt-trino** (next section), so borrow their structure, tests and documentation, and
write your SQL for Trino.

## What happens after merge

Every top-level project with a `dbt_project.yml` on `main` — except the two samples — is
built **once a day** on the platform, in the Airflow DAG `learner_dbt_projects`. You can
watch the runs and read the logs in Airflow.

| | |
|---|---|
| Output | `dbt build` into its own schema `lp_<project>` (hyphens become underscores), readable by every learner in Hue |
| Engine | **dbt-trino**, catalog `iceberg` — write Trino SQL |
| Reads | Only the shared schemas: `crypto_currencies_raw`, `synsap_finance_raw`, `fin_internal_jde` |
| Profile | Supplied by the platform; your `profiles/` folder is ignored |
| Packages | Not available — the sandbox has no internet, so a `packages.yml` fails the build |
| Runtime | 20 minutes; it is stopped after that |

Point sources at the shared schemas by name, for example:

```yaml
sources:
  - name: sap
    schema: synsap_finance_raw
    tables:
      - name: bseg
```

## Try it before you open a pull request

Try your SQL against the real tables in **Hue** — it is the same Trino engine the build
uses. Once merged, the next daily build shows whether the whole project compiles and its
tests pass.

## Recommended: a data contract for every product

Describe what your project publishes in
[`data-contracts`](https://github.com/datapg-labs/data-contracts), under
`product_contracts/`, and link it from your README.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). In short: one folder per project, clone locally,
branch, and open a pull request — a reviewer who isn't the author approves it.
