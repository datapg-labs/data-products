# data-products

dbt projects — the modelling layer that turns raw ingested data into something worth
querying. One folder per project.

## The two sample projects

These come from the platform's own pipelines. Use either as a starting point for your
own project:

| Project | What it builds | Reads | On the platform |
|---|---|---|---|
| [`asset_transactions`](asset_transactions/) | Fixed-asset transactions from the SAP asset tables | `synsap_finance_raw` | Runs daily |
| [`sub_ledger`](sub_ledger/) | SAP open/cleared item indexes (BSID, BSAD, BSIK, BSAK) derived from BSEG | `synsap_finance_raw` | In the pipeline, schedule currently paused |

Both read only tables you can query. Their `profiles/profiles.yml` targets the platform's
own schemas, which you cannot write to: when you copy one, change `schema:` to your own
`pgXXXX` schema.

## Read this first: execution is not wired up yet

You can write dbt projects here and have them reviewed and merged. **Learner projects do
not run on the platform yet.** As of 2026-09-15 there is no path that executes them:

- The JupyterHub image ships pandas, SQLAlchemy, pyspark and the Trino client — **but no
  dbt**
- GitHub-hosted CI cannot reach the platform, so it cannot build against the data
- The platform runs its own projects from a separate, private pipeline

This is stated plainly rather than implied away, because discovering it halfway through
building a model is a waste of your afternoon.

**What you can do today:** write models and tests, read the samples, and try the SQL
against the real tables in Hue. That is genuinely useful — most of the work in a model is
getting the SQL right — but it is not a full loop, and you should know that going in.

**If you want a full loop today**, use [`ingestion`](https://github.com/datapg-labs/ingestion)
instead. Kafka works end to end.

## Recommended: a data contract for every product

Describe what your project publishes in
[`data-contracts`](https://github.com/datapg-labs/data-contracts), under
`product_contracts/`, and link it from your README.

## Querying the lakehouse meanwhile

You do not need dbt to explore the data. Open **Hue** from the launchpad and query Trino
directly. That is the fastest way to understand the tables before you model them, and it
is the same engine dbt would target.

## What would close the gap

1. Add `dbt-trino` to the notebook image, so learners can run `dbt build` against their
   own schema.
2. A platform-side job that builds a merged project against a sandbox schema — never a
   self-hosted runner reachable from pull requests.

If you would find one of these useful, say so in an issue. It is a better signal than a
guess.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). In short: one folder per project, clone locally,
branch, and open a pull request — everything is reviewed before it merges.
