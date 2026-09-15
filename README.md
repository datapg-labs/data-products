# data-products

dbt projects — the modelling layer that turns raw ingested data into something
worth querying.

This repository is a **template**. Click **Use this template** on GitHub to create
your own copy under your own account, and do your work there — see
[CONTRIBUTING.md](CONTRIBUTING.md).

## Read this first: execution is not wired up yet

You can write dbt models in your own repository and read the reference projects
below. **Your models will not run on the platform yet.** As of 2026-09-12 there is
no path that executes a learner's dbt project:

- The JupyterHub image ships pandas, SQLAlchemy, pyspark and the Trino client —
  **but no dbt**
- GitHub-hosted CI cannot reach the platform, so it cannot build against the data
- The platform's own dbt pipelines run from a separate, private repository

This is stated plainly rather than implied away, because discovering it halfway
through building a model is a waste of your afternoon.

**What you can do today:** write models and tests, read the reference projects, and
try the SQL against the real tables in Hue. That is genuinely useful — most of the
work in a model is getting the SQL right — but it is not a full loop, and you
should know that going in.

**If you want a full loop today**, use [`ingestion`](https://github.com/datapg-labs/ingestion)
instead. Kafka works end to end.

## Start your own

Create your repository from this template. You get both reference projects as a
starting point; add your own beside them:

```
my_project/
  dbt_project.yml
  profiles/profiles.yml     schema: your own pgXXXX schema
  models/
  README.md
```

## Reference projects

Two complete dbt projects sit at the top of the repo as worked examples. Read them
before starting your own:

| Project | What it builds | Reads |
|---|---|---|
| [`sub_ledger`](sub_ledger/) | SAP open/cleared item indexes (BSID, BSAD, BSIK, BSAK) derived from BSEG | `synsap_finance_raw` |
| [`asset_transactions`](asset_transactions/) | Fixed-asset transactions from the SAP asset tables | `synsap_finance_raw` |

Both read only tables you can query. Their `profiles/profiles.yml` targets the
platform's own schemas, which you cannot write to: if you adapt one, change
`schema:` to your own `pgXXXX` schema.

## Querying the lakehouse meanwhile

You do not need dbt to explore the data. Open **Hue** from the launchpad and
query Trino directly. That is the fastest way to understand the tables before
you model them, and it is the same engine dbt would target.

## What would close the gap

Either would work, and both are small:

1. Add `dbt-trino` to the notebook image, so learners can run `dbt build` against
   their own schema.
2. A platform-side runner that builds a learner's project against a sandbox schema
   on request — never a self-hosted runner in a learner's repository; see
   [CONTRIBUTING.md](CONTRIBUTING.md).

Meanwhile, `dbt parse` in your own repository's CI needs no platform access and
catches most mistakes before you run anything.

If you would find one of these useful, say so in an issue. It is a better signal
than a guess.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Your projects live in your own repository;
pull requests here are for improving the template and the reference projects.
