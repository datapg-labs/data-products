# Contributing

This repository is a shared codebase, worked on the way a data team works on one:
projects live side by side, every change goes through a pull request, and teammates
review each other's work before it merges.

## How the repository is organised

```
reference/              maintained dbt projects — read them, don't edit them
  sub_ledger/
  asset_transactions/
projects/               learner dbt projects, one directory each
  btc-daily-candles/
    README.md           Authors: @alice, @bob
    dbt_project.yml
    profiles/profiles.yml
    models/
```

- **`reference/`** is kept in shape for everyone. Only maintainers change it.
- **`projects/<name>/`** belongs to the people on its `Authors:` line. Name a project
  after what it builds (`btc-daily-candles`), not after a person.

## Start a project

```bash
git clone https://github.com/datapg-labs/data-products.git
cd data-products
git checkout -b btc-daily-candles
cp -r reference/sub_ledger projects/btc-daily-candles    # or start from scratch
```

1. Add `projects/btc-daily-candles/README.md` with your handle on its `Authors:` line:
   `Authors: @your-github-user` — and say what the project builds and from which tables.
2. Rename the project in `dbt_project.yml`, and point `schema:` in
   `profiles/profiles.yml` at your own `pgXXXX` schema when you run it.
3. Commit, push your branch, and open a pull request.

If you have not accepted your `datapg-labs` invitation yet, fork the repository and
open the pull request from your fork — everything else is the same.

## Work on someone else's project

Projects are meant to be shared. To join one, open a pull request whose **only**
change adds your handle to that project's `Authors:` line. One of its authors reviews
it; once it merges you work on the project like any other author.

To suggest a change without joining, open an issue or comment on a pull request.

## Reviews

A pull request merges when it has:

1. **A peer review.** Ask a teammate — an author of the project, or anyone who knows
   the area. Reviewing is half of what this repository teaches: read the SQL, try it
   against the real tables in Hue, ask questions, suggest changes.
2. **A maintainer's approval.** Maintainers merge; you don't need to chase them.
3. **A passing scope check** (next section).

What a good review looks for:

- Does the model do what its README says, and is the grain stated?
- Are keys and tests declared — `unique`, `not_null` on what must be unique?
- Does it read only tables you can query (`synsap_finance_raw`, `fin_internal_jde`,
  `crypto_currencies_raw`)?
- No credentials, tokens, keys, or `.env` files. Not even fake-looking ones.

Expect comments on your pull requests; they are meant to teach, not to reject.

## The scope check

An automated check runs on every pull request. It fails, and says exactly which file
and why, when a pull request:

- changes anything outside `projects/` — `reference/`, the docs, `.github/` — unless
  you are a maintainer
- changes a project you are not an author of (joining, as above, is the exception)
- adds a project without a `README.md` that lists you on its `Authors:` line
- adds a credentials file (`.env`, `*.pem`, a private key) or a line that looks like a
  hard-coded password, token or key

## Clone locally, with your own GitHub account

**Do not use the browser-based VS Code on the platform for git work.** It is a
shared workspace. Pushing from it would mean putting your GitHub credentials
somewhere other people can reach, and any commit you made would be attributed to
whoever set the workspace up. Clone to your own machine, with your own identity.

## Where your code runs

The platform's services — Kafka, Trino, the lakehouse — are only reachable from
inside the platform. Try your SQL in **Hue** or **JupyterHub**, then copy it into your
local clone to commit. Your laptop and GitHub Actions cannot reach those services, and
dbt itself is not yet wired up to run on the platform — see the README.

## Platform limits

| Limit | Value |
|---|---|
| Shared datasets | Read-only |
| Your lakehouse schema | `pgXXXX` — the only place you can create tables |
| Your schema's storage | 20 GiB |

On a shared project, each author runs it against their own schema — don't commit
one person's schema as the only option.

## CI

Workflows run on **GitHub-hosted runners** only, and live in `.github/`, which
maintainers look after. Never add `runs-on: self-hosted` — a pull request that does
will be closed.

## Getting your credentials

Your platform credentials are at
**[datapg.dev/credentials](https://datapg.dev/credentials)** once you are signed
in. They are yours; anyone you share them with is acting as you. Never commit them —
read them from the environment instead.
