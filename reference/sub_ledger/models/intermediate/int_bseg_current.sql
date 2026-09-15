-- The current image of every BSEG line.
--
-- Change capture sends one record per write, so a line that was posted, amended
-- and then archived appears three times. Taking the latest by __ts and dropping
-- the deletes is what turns a change stream back into the table it came from;
-- without it an amended invoice would be counted twice and an archived one
-- would still be owed.
--
-- This is the expensive model in the project: the ranking shuffles the entire
-- ledger, and on a single-node Spark it is what decides whether the run
-- survives. Two things keep it affordable - it is materialised so the work
-- happens once rather than once per consumer, and only the columns the
-- sub-ledger actually needs are carried through the shuffle. BSEG has around a
-- hundred; thirty of them travel.

{{ config(
    partition_by=['fiscal_year'],
    table_properties={
        'write.parquet.compression-codec': 'zstd',
        'write.distribution-mode': 'hash'
    }
) }}

WITH ranked AS (
    SELECT
        mandt                       AS client,
        bukrs                       AS company_code,
        gjahr                       AS fiscal_year,
        belnr                       AS document_number,
        buzei                       AS document_line,
        koart                       AS account_type,
        kunnr                       AS customer_number,
        lifnr                       AS vendor_number,
        racct                       AS gl_account,
        drcrk                       AS debit_credit_indicator,
        blart                       AS document_type,
        CAST(budat AS DATE)         AS posting_date,
        CAST(bldat AS DATE)         AS document_date,
        rtcur                       AS document_currency,
        rhcur                       AS local_currency,
        CAST(tsl AS DECIMAL(18,2))  AS amount_doc_currency,
        CAST(hsl AS DECIMAL(18,2))  AS amount_local_currency,
        CAST(ksl AS DECIMAL(18,2))  AS amount_group_currency,
        rassc                       AS trading_partner,
        prctr                       AS profit_center,
        segment,
        zlsch                       AS payment_method,
        zuonr                       AS assignment_number,
        xblnr                       AS reference_document,
        xref1                       AS reference_key,
        rebzg                       AS invoice_reference,
        rebzj                       AS invoice_reference_year,
        augbl                       AS clearing_document_flagged,
        CAST(augdt AS DATE)         AS clearing_date_flagged,
        xreversed,
        __op,
        __ts,

        ROW_NUMBER() OVER (
            PARTITION BY mandt, bukrs, gjahr, belnr, buzei
            ORDER BY __ts DESC
        ) AS rn
    FROM {{ source('sap_finance_raw', 'bseg') }}
)

SELECT *
FROM ranked
WHERE rn = 1
  AND __op <> 'D'
