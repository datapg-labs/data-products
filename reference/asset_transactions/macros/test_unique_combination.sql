{#
  Self-contained combination-uniqueness test (no dbt_utils dependency, so the project
  parses without `dbt deps`). Fails if any set of the given columns occurs more than once.

  Usage in a schema yml:
      tests:
        - unique_combination:
            combination_of_columns: [col_a, col_b, col_c]
#}
{% test unique_combination(model, combination_of_columns) %}

with validation as (
    select
        {{ combination_of_columns | join(', ') }},
        count(*) as _n
    from {{ model }}
    group by {{ combination_of_columns | join(', ') }}
    having count(*) > 1
)

select * from validation

{% endtest %}
