with source as (
    select * from {{ source('sap_s4', 'anlz') }}
),
renamed as (
    select
        bukrs as company_code,
        anln1 as asset_main_number,
        anln2 as asset_sub_number,
        try_cast(bdatu as date) as valid_to_date,
        try_cast(adatu as date) as valid_from_date,
        kostl as cost_center,
        werksi as plant,
        gsber as business_area,
        prctr as profit_center,
        segment as segment,
        lstar as activity_type
    from source
),
-- Time-dependent allocations re-emit without a version column, and the source carries
-- many overlapping slices per asset (all open-ended). Collapse to the current slice -
-- the one with the latest valid-from - so there is exactly one organisational
-- assignment per asset for the master dimension.
current_slice as (
    select *,
        row_number() over (
            partition by company_code, asset_main_number, asset_sub_number
            order by valid_from_date desc nulls last
        ) as _rn
    from renamed
)
select
    company_code,
    asset_main_number,
    asset_sub_number,
    valid_to_date,
    valid_from_date,
    cost_center,
    plant,
    business_area,
    profit_center,
    segment,
    activity_type
from current_slice
where _rn = 1
