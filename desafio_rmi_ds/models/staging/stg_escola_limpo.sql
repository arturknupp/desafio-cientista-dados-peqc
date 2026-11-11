{{
    config(
        materialized='table'
    )
}}

SELECT 
  id_escola,
  bairro
FROM {{ source('educacao_raw', 'stg_escola') }} 
WHERE id_escola is not null 
