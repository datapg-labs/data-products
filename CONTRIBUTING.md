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
  models/
```

Each project gets its own folder with a short `README.md`: what it builds, from which
tables, at what grain, and who built it. Name the folder after what it builds, not after a
person — the name becomes its output schema, `lp_btc_daily_candles`.

## Recommended: a data contract for every product

A data product is a promise to whoever queries it. Describe it in
[`data-contracts`](https://github.com/datapg-labs/data-contracts) under
`product_contracts/`, and link the contract from your project's README.

## The flow

```bash
git clone https://github.com/datapg-labs/data-products.git
cd data-products
git checkout -b btc-daily-candles
mkdir btc-daily-candles
```

1. Add `dbt_project.yml`, `models/` and a README. Borrow structure and tests from the
   samples, but write **Trino SQL** — your project is built with dbt-trino.
2. Try the SQL against the real tables in Hue.
3. Commit, push your branch, and open a pull request. In the description, say what it
   builds and what you learned.

If you cannot push branches to `datapg-labs`, fork the repository and open the pull
request from your fork; everything else is the same.

## Reviews and merging

A pull request merges once a member of the **reviewers** team approves it — someone other
than the author. Anyone can comment on and learn from any pull request; ask for a review
when yours is ready.

## What happens after merge

Merged projects are built **once a day** into `lp_<project>`, as a sandboxed dbt-trino run
that can read the shared schemas and write only its own output. See the
[README](README.md#what-happens-after-merge) for the details that affect your project.

## What a review looks for

- Does it stay inside its own project folder?
- Does the README state the grain, and link a data contract?
- Is the SQL valid Trino, reading only `crypto_currencies_raw`, `synsap_finance_raw` or
  `fin_internal_jde`?
- Are keys and tests declared — `unique` and `not_null` on what must be unique?
- No `packages.yml`, no credentials, tokens, keys or `.env` files.

Expect comments; they are meant to teach, not to reject.

## Clone locally, with your own GitHub account

**Do not use the browser-based VS Code on the platform for git work.** It is a shared
workspace. Pushing from it would mean putting your GitHub credentials somewhere other
people can reach, and any commit you made would be attributed to whoever set the
workspace up. Clone to your own machine, with your own identity.

## Platform limits

| Limit | Value |
|---|---|
| Shared datasets | Read-only |
| Your personal lakehouse schema | `pgXXXX` — for your own experiments in Hue |
| Merged project output | `lp_<project>`, rebuilt daily |

## CI

Workflows run on **GitHub-hosted runners** only. Never add `runs-on: self-hosted` — a
pull request that does will be closed.

## Getting your credentials

Your platform credentials are at
**[datapg.dev/credentials](https://datapg.dev/credentials)** once you are signed in. They
are yours; anyone you share them with is acting as you. Never commit them — read them
from the environment instead.
