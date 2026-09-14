with anla as (
    select * from {{ ref('stg_sap__anla') }}
),
anlz as (
    -- Already reduced to one current allocation per asset in staging.
    select * from {{ ref('stg_sap__anlz') }}
),
joined as (
    select
        anla.company_code,
        anla.asset_main_number,
        anla.asset_sub_number,
        anla.asset_description,
        anla.asset_class,
        anla.capitalization_date,
        anla.deactivation_date,
        anla.created_by,
        anla.created_date,
        anla.changed_by,
        anla.changed_date,
        anla.first_acquisition_date,
        anla.inventory_number,
        anla.vendor_account,
        anla.account_determination,
        anla.is_deleted,
        anlz.cost_center,
        anlz.plant,
        anlz.business_area,
        anlz.profit_center,
        anlz.segment,
        anlz.activity_type,
        anlz.valid_from_date,
        anlz.valid_to_date
    from anla
    left join anlz
        on anla.company_code = anlz.company_code
        and anla.asset_main_number = anlz.asset_main_number
        and anla.asset_sub_number = anlz.asset_sub_number
)
select * from joined
