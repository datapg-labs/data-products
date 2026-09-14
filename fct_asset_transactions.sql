with transactions as (
    select * from {{ ref('int_asset_transactions_enriched') }}
),
dim_asset as (
    select * from {{ ref('dim_asset') }}
)
select
    md5(concat_ws('|',
        coalesce(cast(t.company_code as string), '∅'),
        coalesce(cast(t.asset_main_number as string), '∅'),
        coalesce(cast(t.asset_sub_number as string), '∅'),
        coalesce(cast(t.fiscal_year as string), '∅'),
        coalesce(cast(t.document_number as string), '∅'),
        coalesce(cast(t.document_line_item as string), '∅'),
        coalesce(cast(t.depreciation_area as string), '∅'),
        coalesce(cast(t.subledger_line_item_type as string), '∅')
    )) as transaction_key,
    md5(concat_ws('|',
        coalesce(cast(t.company_code as string), '∅'),
        coalesce(cast(t.asset_main_number as string), '∅'),
        coalesce(cast(t.asset_sub_number as string), '∅')
    )) as asset_key,
    
    t.company_code,
    t.fiscal_year,
    t.fiscal_period,
    t.document_number,
    t.document_line_item,
    t.subledger_line_item_type,
    t.depreciation_area,
    t.transaction_type_code,
    t.posting_date,
    t.document_date,
    t.asset_value_date,
    t.document_type,
    t.transaction_code,
    t.user_name,
    t.currency_key,
    t.document_header_text,
    
    coalesce(t.amount_cc, t.anep_amount) as amount_in_local_currency,
    t.amount_gc as amount_in_global_currency,
    
    -- Classified on the sub-ledger line item type, not the transaction type.
    --
    -- The source stamps transaction_type_code 100 on every row, acquisitions
    -- and depreciation runs alike, so classifying on it called all 2m rows
    -- 'Acquisition' - and the two netted to roughly nothing, which is how a
    -- balance sheet ends up reporting -0.3bn of property.
    --
    -- The sub-ledger line item type does distinguish them: 90000 is the
    -- acquisition posting, 90001 the depreciation charge. Transaction type is
    -- kept as a fallback so the day the source is fixed, the finer codes still
    -- resolve.
    case
        when t.subledger_line_item_type = '90000' then 'Acquisition'
        when t.subledger_line_item_type = '90001' then 'Depreciation'
        when t.transaction_type_code in ('200', '210', '250', '290') then 'Retirement'
        when t.transaction_type_code in ('300', '310', '320', '330') then 'Transfer'
        when t.transaction_type_code in ('110', '120', '140') then 'Acquisition'
        when t.transaction_type_code in ('500') then 'Depreciation'
        else 'Other'
    end as transaction_category

from transactions as t
inner join dim_asset as a
    on t.company_code = a.company_code
    and t.asset_main_number = a.asset_main_number
    and t.asset_sub_number = a.asset_sub_number
