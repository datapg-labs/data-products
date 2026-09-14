with source as (
    select * from {{ source('sap_s4', 'faat_doc_it') }}
),
renamed as (
    select
        bukrs as company_code,
        anln1 as asset_main_number,
        anln2 as asset_sub_number,
        gjahr as fiscal_year,
        belnr as document_number,
        docln as document_line_item,
        slalittype as subledger_line_item_type,
        tsl as amount_in_transaction_currency,
        hsl as amount_in_company_code_currency,
        ksl as amount_in_global_currency,
        osl as amount_in_freely_defined_currency,
        bwasl as transaction_type_code,
        afabe as depreciation_area,
        try_cast(bzdat as date) as asset_value_date
    from source
)
select * from renamed
