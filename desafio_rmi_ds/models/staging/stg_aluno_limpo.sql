{{
    config(
        materialized='table'
    )
}}

SELECT
    id_aluno,
    id_turma,

    CASE
        WHEN faixa_etaria IS NULL THEN NULL
        WHEN faixa_etaria NOT IN (
            '0-5',
            '6-10',
            '11-14',
            '15-17',
            '18+'
        ) THEN 'Desconhecida'
        ELSE faixa_etaria
    END AS faixa_etaria,

    bairro

FROM {{ source('educacao_raw', 'stg_aluno') }}

WHERE id_aluno IS NOT NULL
