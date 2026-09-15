-- Every sub-ledger item, with whether it has been paid.
--
-- Clearing is established from the PAYMENT document rather than from the
-- clearing flag on the invoice. In SAP the flag (AUGBL) is written back onto
-- the open item when it clears, but the source system only stamps it on
-- documents it still holds in memory, so reading the flag alone reported the
-- overwhelming majority of settled invoices as still outstanding. The payment
-- document always carries a reference back to the invoice it settles (REBZG),
-- and that reference is present on every payment, so it is the reliable side of
-- the relationship.
--
-- The item rows and the payment rows are the two halves of the same population:
-- an invoice line carries the customer or vendor and a debit for a receivable
-- or a credit for a payable; the payment line carries the counter-entry and the
-- back-reference.

WITH lines AS (
    SELECT * FROM {{ ref('int_bseg_current') }}
),

-- One row per invoice that has been settled, naming the document that settled
-- it. A part-paid invoice can be referenced more than once, so this is reduced
-- to the last payment: an item is open or it is not.
clearings AS (
    SELECT
        client,
        company_code,
        invoice_reference_year               AS fiscal_year,
        invoice_reference                    AS document_number,
        MAX(document_number)                 AS clearing_document,
        MAX(posting_date)                    AS clearing_date,
        SUM(ABS(amount_local_currency))      AS amount_cleared_local
    FROM lines
    WHERE invoice_reference IS NOT NULL
      AND invoice_reference <> ''
    GROUP BY client, company_code, invoice_reference_year, invoice_reference
),

-- The open-item population: invoice lines on a customer or vendor account.
-- Payment lines are excluded by their debit/credit indicator, so a payment is
-- never mistaken for a new item owed.
-- The date the ledger has actually been written up to.
--
-- Ageing an open item against today's real date assumes the ledger is current.
-- When it is not — a load still in flight, a source that stopped feeding, a
-- historical rebuild — every unpaid invoice is aged by the gap between the data
-- and the calendar rather than by anything the business did. Measured against a
-- ledger written up to July while the calendar said August, open items aged at
-- an average of 417 days and every ageing bucket was meaningless.
--
-- So an item ages against the ledger's own high-water mark. When the ledger is
-- current that is today and nothing changes; when it is behind, ageing stays
-- measured in business time rather than in how stale the feed is.
reporting_date AS (
    SELECT MAX(posting_date) AS as_at
    FROM lines
),

items AS (
    SELECT *
    FROM lines
    WHERE account_type IN ('D', 'K')
      AND (
            (account_type = 'D' AND debit_credit_indicator = 'S')   -- receivable raised
         OR (account_type = 'K' AND debit_credit_indicator = 'H')   -- payable raised
          )
      AND COALESCE(xreversed, '') <> 'X'
)

SELECT
    i.client,
    i.company_code,
    i.fiscal_year,
    i.document_number,
    i.document_line,
    i.account_type,
    i.customer_number,
    i.vendor_number,
    i.gl_account,
    i.document_type,
    i.posting_date,
    i.document_date,
    i.document_currency,
    i.local_currency,
    ABS(i.amount_doc_currency)   AS amount_doc_currency,
    ABS(i.amount_local_currency) AS amount_local_currency,
    ABS(i.amount_group_currency) AS amount_group_currency,
    i.debit_credit_indicator,
    i.trading_partner,
    i.profit_center,
    i.segment,
    i.payment_method,
    i.assignment_number,
    i.reference_document,
    i.reference_key,

    c.clearing_document,
    c.clearing_date,
    CASE WHEN c.clearing_document IS NOT NULL THEN 'CLEARED' ELSE 'OPEN' END AS clearing_status,

    -- Days the item has been outstanding: to the day it was paid if it was, and
    -- to the ledger's as-at date if it is still owed. One column so ageing is
    -- the same calculation on both sides of the sub-ledger.
    DATEDIFF(COALESCE(c.clearing_date, r.as_at), i.posting_date) AS days_outstanding

FROM items i
CROSS JOIN reporting_date r
LEFT JOIN clearings c
    ON  i.client          = c.client
    AND i.company_code    = c.company_code
    AND i.fiscal_year     = c.fiscal_year
    AND i.document_number = c.document_number
