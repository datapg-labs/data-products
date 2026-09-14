with asset_master as (
    select * from {{ ref('int_asset_master_time_dependent') }}
)
select
    md5(concat_ws('|',
        coalesce(cast(company_code as string), '∅'),
        coalesce(cast(asset_main_number as string), '∅'),
        coalesce(cast(asset_sub_number as string), '∅')
    )) as asset_key,
    company_code,
    asset_main_number,
    asset_sub_number,
    concat(asset_main_number, '-', asset_sub_number) as asset_id,
    asset_description,
    asset_class,
    capitalization_date,
    deactivation_date,
    first_acquisition_date,
    inventory_number,
    vendor_account,
    account_determination,
    cost_center,
    plant,
    business_area,
    profit_center,
    segment,
    activity_type,
    case 
        when asset_class like '2%' then 'Machinery & Equipment'
        when asset_class like '3%' then 'IT Hardware'
        when asset_class like '4%' then 'Fixtures & Fittings'
        else 'Other Assets'
    end as asset_category,
    case 
        when deactivation_date is not null then 'Deactivated'
        when capitalization_date is not null then 'Capitalized'
        else 'Under Construction / Acquired'
    end as asset_status,
    is_deleted
from asset_master
