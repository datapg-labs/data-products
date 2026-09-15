with faat as (
    select * from {{ ref('stg_sap__faat_doc_it') }}
),
anep as (
    select * from {{ ref('stg_sap__anep') }}
),
bkpf as (
    select * from {{ ref('stg_sap__bkpf') }}
),
-- ANEP is legacy and is not unique on the columns FAAT joins to (a single asset/year/
-- transaction-type/area spans many documents). Pre-aggregate to that grain so the join
-- to FAAT stays 1:1 and cannot fan the fact table out. ANEP only supplies a fallback
-- amount and a sequence hint; the modern FAAT record carries the authoritative values.
anep_agg as (
    select
        company_code,
        asset_main_number,
        asset_sub_number,
        fiscal_year,
        transaction_type_code,
        depreciation_area,
        min(sequence_number) as sequence_number,
        sum(transaction_amount) as anep_amount
    from anep
    group by
        company_code, asset_main_number, asset_sub_number,
        fiscal_year, transaction_type_code, depreciation_area
),
joined as (
    select
        faat.company_code,
        faat.asset_main_number,
        faat.asset_sub_number,
        faat.fiscal_year,
        faat.document_number,
        faat.document_line_item,
        faat.subledger_line_item_type,
        faat.transaction_type_code,
        faat.depreciation_area,
        faat.asset_value_date,
        faat.amount_in_company_code_currency as amount_cc,
        faat.amount_in_global_currency as amount_gc,

        -- Bring in BKPF header info
        bkpf.document_type,
        bkpf.posting_date,
        bkpf.document_date,
        bkpf.fiscal_period,
        bkpf.user_name,
        bkpf.transaction_code,
        bkpf.currency_key,
        bkpf.document_header_text,

        -- Fallback amount / sequence from legacy ANEP (pre-aggregated, no fan-out)
        anep_agg.sequence_number,
        anep_agg.anep_amount

    from faat
    left join bkpf
        on faat.company_code = bkpf.company_code
        and faat.document_number = bkpf.document_number
        and faat.fiscal_year = bkpf.fiscal_year
    left join anep_agg
        on faat.company_code = anep_agg.company_code
        and faat.asset_main_number = anep_agg.asset_main_number
        and faat.asset_sub_number = anep_agg.asset_sub_number
        and faat.fiscal_year = anep_agg.fiscal_year
        and faat.transaction_type_code = anep_agg.transaction_type_code
        and faat.depreciation_area = anep_agg.depreciation_area
)
select * from joined
