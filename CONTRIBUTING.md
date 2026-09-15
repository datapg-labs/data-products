# Contributing

Everything reaches `main` through a pull request, and every pull request is reviewed
before it merges. That is the workflow a real data team uses, and practising it is part
of the point.

## Where things go

```
sub_ledger/              sample project from the platform's own pipelines
asset_transactions/      sample project from the platform's own pipelines
btc-daily-candles/       your project — one folder per dbt project
  README.md
  dbt_project.yml
  profiles/profiles.yml
  models/
```

Each project gets its own folder with a short `README.md`: what it builds, from which
tables, at what grain, and who built it. Name the folder after what it builds, not after a
person.

## Recommended: a data contract for every product

A data product is a promise to whoever queries it. Describe it in
[`data-contracts`](https://github.com/datapg-labs/data-contracts) under
`product_contracts/`, and link the contract from your project's README.

## The flow

```bash
git clone https://github.com/datapg-labs/data-products.git
cd data-products
git checkout -b btc-daily-candles
cp -r asset_transactions btc-daily-candles     # or start from scratch
```

1. Rename the project in `dbt_project.yml`, and set `schema:` in `profiles/profiles.yml`
   to your own `pgXXXX` schema.
2. Write the README and the models. Try the SQL against the real tables in Hue.
3. Commit, push your branch, and open a pull request. In the description, say what it
   builds and what you learned.

If you cannot push branches to `datapg-labs`, fork the repository and open the pull
request from your fork; everything else is the same.

## What a review looks for

- Does it stay inside its own project folder?
- Does the README state the grain, and link a data contract?
- Are keys and tests declared — `unique` and `not_null` on what must be unique?
- Does it read only tables you can query (`crypto_currencies_raw`, `synsap_finance_raw`,
  `fin_internal_jde`)?
- No credentials, tokens, keys, or `.env` files. Not even fake-looking ones.

Expect comments; they are meant to teach, not to reject.

## Clone locally, with your own GitHub account

**Do not use the browser-based VS Code on the platform for git work.** It is a shared
workspace. Pushing from it would mean putting your GitHub credentials somewhere other
people can reach, and any commit you made would be attributed to whoever set the
workspace up. Clone to your own machine, with your own identity.

## Where your code runs

The platform's services — Kafka, Trino, the lakehouse — are only reachable from inside
the platform. Try your SQL in **Hue** or **JupyterHub**, then copy it into your local
clone to commit. dbt itself is not yet wired up to run learner projects — see the README.

## Platform limits

| Limit | Value |
|---|---|
| Shared datasets | Read-only |
| Your lakehouse schema | `pgXXXX` — the only place you can create tables |
| Your schema's storage | 20 GiB |

## CI

Workflows run on **GitHub-hosted runners** only. Never add `runs-on: self-hosted` — a
pull request that does will be closed.

## Getting your credentials

Your platform credentials are at
**[datapg.dev/credentials](https://datapg.dev/credentials)** once you are signed in. They
are yours; anyone you share them with is acting as you. Never commit them — read them
from the environment instead.
