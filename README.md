# data-products

dbt projects — the modelling layer that turns raw ingested data into something
worth querying.

## Read this first: execution is not wired up yet

You can write models here, and they will be reviewed and merged. **They will not
run.** As of 2026-09-12 there is no path that executes a learner's dbt project:

- The JupyterHub image ships pandas, SQLAlchemy and pyspark — **no dbt, and no
  Trino client**
- There is no CI job that builds pull requests
- The platform's own dbt pipelines run from a separate, private repository

This is stated plainly rather than implied away, because discovering it halfway
through building a model is a waste of your afternoon.

**What you can do today:** write models and tests, have them reviewed, and read
the existing ones. That is genuinely useful — SQL review is most of the job — but
it is not a full loop, and you should know that going in.

**If you want a full loop today**, use [`ingestion`](https://github.com/datapg-labs/ingestion)
instead. Kafka works end to end.

## Layout

```
<your-pg-id>/
  my_project/
    dbt_project.yml
    models/
    README.md
```

## Querying the lakehouse meanwhile

You do not need dbt to explore the data. Open **Hue** from the launchpad and
query Trino directly. That is the fastest way to understand the tables before
you model them, and it is the same engine dbt would target.

## What would close the gap

Either would work, and both are small:

1. Add `dbt-trino` to the notebook image, so learners can run `dbt build` against
   their own schema.
2. Add a GitHub-hosted CI workflow that runs `dbt parse` and `dbt build` against
   a sandbox schema on pull requests. No self-hosted runners — see
   [CONTRIBUTING.md](CONTRIBUTING.md).

If you would find one of these useful, say so in an issue. It is a better signal
than a guess.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
