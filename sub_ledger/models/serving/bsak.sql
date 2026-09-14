-- Vendor cleared items - payables that have been paid.
--
-- Column names are SAP's, not the warehouse's, because these tables stand in
-- for the source tables of the same name: the payables and receivables products
-- read them exactly as they would read the originals. What has changed is where
-- they come from — derived from BSEG on every run rather than hand-loaded once,
-- so they cannot drift away from the ledger.

SELECT
    client                  AS mandt,
    company_code            AS bukrs,
    vendor_number                      AS lifnr,
    fiscal_year             AS gjahr,
    document_number         AS belnr,
    document_line           AS buzei,
    document_type           AS blart,
    posting_date            AS budat,
    document_date           AS bldat,
    document_currency       AS waers,
    amount_doc_currency     AS wrbtr,
    amount_local_currency   AS dmbtr,
    amount_group_currency   AS kslbtr,
    debit_credit_indicator  AS shkzg,
    payment_method          AS zlsch,
    assignment_number       AS zuonr,
    reference_document      AS xblnr,
    reference_key           AS xref1,
    trading_partner         AS rassc,
    profit_center           AS prctr,
    segment,
    gl_account              AS hkont,
    clearing_document       AS augbl,
    clearing_date           AS augdt,
    clearing_status,
    days_outstanding
FROM {{ ref('int_open_items') }}
WHERE account_type = 'K'
  AND clearing_status = 'CLEARED'
