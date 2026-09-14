with source as (
    select * from {{ source('sap_s4', 'anep') }}
),
renamed as (
    select
        bukrs as company_code,
        anln1 as asset_main_number,
        anln2 as asset_sub_number,
        gjahr as fiscal_year,
        -- Real ANEP sequence column is LNSAN (the model previously referenced a
        -- non-existent LNRHA). LNSAN alone is not unique per row; the document
        -- number and line are what carry the grain, so they are selected too.
        lnsan as sequence_number,
        belnr as document_number,
        buzei as document_line,
        afabe as depreciation_area,
        bwasl as transaction_type_code,
        try_cast(bzdat as date) as asset_value_date,
        anbtr as transaction_amount
    from source
)
select * from renamed
