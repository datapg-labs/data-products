with source as (
    select * from {{ source('sap_s4', 'anla') }}
),
renamed as (
    select
        bukrs as company_code,
        anln1 as asset_main_number,
        anln2 as asset_sub_number,
        anlkl as asset_class,
        txt50 as asset_description,
        try_cast(aktiv as date) as capitalization_date,
        try_cast(deakt as date) as deactivation_date,
        ernam as created_by,
        try_cast(erdat as date) as created_date,
        aenam as changed_by,
        try_cast(aedat as date) as changed_date,
        try_cast(zugdt as date) as first_acquisition_date,
        invnr as inventory_number,
        lifnr as vendor_account,
        ktogr as account_determination,
        xloev as is_deleted
    from source
),
-- ANLA has no CDC version column and the source re-emits each asset many times.
-- Collapse to one current master per asset (latest by change/creation date) so the
-- asset key is unique for the downstream dimension.
deduplicated as (
    select *,
        row_number() over (
            partition by company_code, asset_main_number, asset_sub_number
            order by changed_date desc nulls last, created_date desc nulls last
        ) as _rn
    from renamed
)
select
    company_code,
    asset_main_number,
    asset_sub_number,
    asset_class,
    asset_description,
    capitalization_date,
    deactivation_date,
    created_by,
    created_date,
    changed_by,
    changed_date,
    first_acquisition_date,
    inventory_number,
    vendor_account,
    account_determination,
    is_deleted
from deduplicated
where _rn = 1
