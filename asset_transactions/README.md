# asset_transactions

Fixed-asset transactions modelled from the SAP asset tables in `synsap_finance_raw`
(ANLA, ANEP, ANLZ, the FAAT document items and BKPF headers), staged under `models/staging/sap/`,
joined in `models/intermediate/finance/` and published from `models/marts/finance/`.

> **Adapting this project:** `profiles/profiles.yml` writes to `synsap_finance_assets`,
> a platform schema you cannot write to. Change `schema:` to your own `pgXXXX` schema
> first.
