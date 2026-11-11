{{
    config(
        materialized='table'
    )
}}

SELECT 
ano,
id_turma,
id_aluno 
FROM {{ source('educacao_raw', 'stg_turma') }} 
WHERE id_aluno IS NOT NULL
AND id_turma IS NOT NULL
AND ano BETWEEN EXTRACT(YEAR FROM CURRENT_DATE()) - 200
    AND EXTRACT(YEAR FROM CURRENT_DATE())
