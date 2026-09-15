# data-products

dbt projects — the modelling layer that turns raw ingested data into something
worth querying.

This is a shared repository: projects live side by side in `projects/`, changes go
through pull requests, and teammates review each other's work. See
[CONTRIBUTING.md](CONTRIBUTING.md).

## Read this first: execution is not wired up yet

You can write dbt models in `projects/` and have them reviewed and merged. **They will
not run on the platform yet.** As of 2026-09-12 there is no path that executes a
learner's dbt project:

- The JupyterHub image ships pandas, SQLAlchemy, pyspark and the Trino client —
  **but no dbt**
- GitHub-hosted CI cannot reach the platform, so it cannot build against the data
- The platform's own dbt pipelines run from a separate, private repository

This is stated plainly rather than implied away, because discovering it halfway
through building a model is a waste of your afternoon.

**What you can do today:** write models and tests, review each other's, read the
reference projects, and try the SQL against the real tables in Hue. That is genuinely
useful — SQL review is most of the job — but it is not a full loop, and you should
know that going in.

**If you want a full loop today**, use [`ingestion`](https://github.com/datapg-labs/ingestion)
instead. Kafka works end to end.

## Layout

```
reference/          maintained dbt projects — read, don't edit
  sub_ledger/
  asset_transactions/
projects/<name>/    learner projects — README.md lists the authors
```

## Reference projects

Two complete dbt projects, kept in shape as worked examples. Read them before
starting your own:

| Project | What it builds | Reads |
|---|---|---|
| [`sub_ledger`](reference/sub_ledger/) | SAP open/cleared item indexes (BSID, BSAD, BSIK, BSAK) derived from BSEG | `synsap_finance_raw` |
| [`asset_transactions`](reference/asset_transactions/) | Fixed-asset transactions from the SAP asset tables | `synsap_finance_raw` |

Both read only tables you can query. Their `profiles/profiles.yml` targets the
platform's own schemas, which you cannot write to: if you start from one, change
`schema:` to your own `pgXXXX` schema.

## Querying the lakehouse meanwhile

You do not need dbt to explore the data. Open **Hue** from the launchpad and
query Trino directly. That is the fastest way to understand the tables before
you model them, and it is the same engine dbt would target.

## What would close the gap

Either would work, and both are small:

1. Add `dbt-trino` to the notebook image, so learners can run `dbt build` against
   their own schema.
2. A platform-side runner that builds a merged project against a sandbox schema —
   never a self-hosted runner reachable from pull requests; see
   [CONTRIBUTING.md](CONTRIBUTING.md).

If you would find one of these useful, say so in an issue. It is a better signal
than a guess.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). In short: work in `projects/<name>/` with your
handle on its `Authors:` line, branch and open a pull request; a teammate reviews it and
a maintainer merges.
