with source as (
    select * from {{ source('sap_s4_raw', 'bkpf') }}
),
renamed as (
    select
        bukrs as company_code,
        belnr as document_number,
        gjahr as fiscal_year,
        blart as document_type,
        try_cast(bldat as date) as document_date,
        try_cast(budat as date) as posting_date,
        lpad(cast(
            case
                when month(try_cast(budat as date)) >= 4 then month(try_cast(budat as date)) - 3
                else month(try_cast(budat as date)) + 9
            end as string), 3, '0') as fiscal_period,
        cpudt as entry_date,
        cputm as entry_time,
        usnam as user_name,
        tcode as transaction_code,
        waers as currency_key,
        kursf as exchange_rate,
        bktxt as document_header_text,
        awtyp as reference_procedure,
        awkey as reference_key
    from source
)
select * from renamed
