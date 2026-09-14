# sub_ledger

Rebuilds the SAP open-item index tables from BSEG on every run:

| Table | Contents |
|---|---|
| `bsid` | customer open items |
| `bsad` | customer cleared items |
| `bsik` | vendor open items |
| `bsak` | vendor cleared items |

These are indexes over BSEG in SAP, not independent postings, so deriving them
is what they are. The tables they replace had been loaded once by hand and had
no pipeline behind them; by the time anyone looked they had drifted far enough
from the ledger that the payables product was reporting on invoices the general
ledger no longer contained. A derived table cannot drift.

They are written to `synsap_finance`, the product schema, rather than to
`synsap_finance_raw`. The raw schema is the CDC landing zone and holds only what
the source system sent; anything built belongs on the other side of that line.

Consumed by
[fin-invoice-to-pay](https://github.com/blueprint-demo-org/fin-invoice-to-pay)
and
[credit_to_cash](https://github.com/blueprint-demo-org/credit_to_cash), so this
project has to run before either of them.

## Clearing

Clearing status comes from the payment document, not from the clearing flag on
the invoice. SAP writes AUGBL back onto the open item when it clears, but the
source system only stamps it on documents it still holds in memory, so reading
the flag alone reported the overwhelming majority of settled invoices as still
outstanding. Every payment carries a reference back to the invoice it settles,
and that reference is always present, so the relationship is read from that side.
