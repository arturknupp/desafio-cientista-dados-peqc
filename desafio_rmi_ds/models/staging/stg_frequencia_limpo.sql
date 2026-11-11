{{
    config(
        materialized='table'
    )
}}

SELECT 
id_escola,
id_aluno, 
id_turma, 
TRIM(data_inicio) data_inicio, 
TRIM(data_fim) data_fim,
CASE WHEN disciplina IS NULL THEN disciplina
     WHEN disciplina NOT IN ('disciplina_1','disciplina_2','disciplina_3','disciplina_4') THEN 'Desconhecido'
ELSE disciplina END disciplina,
CASE WHEN frequencia IS NULL THEN frequencia 
     WHEN frequencia > 100.0 THEN 100.0
     WHEN frequencia < 0.0 THEN 0.0
ELSE frequencia END frequencia
 FROM {{ source('educacao_raw', 'stg_frequencia') }} 
WHERE id_aluno IS NOT NULL
AND id_escola IS NOT NULL
AND id_turma IS NOT NULL 
AND SAFE.PARSE_DATE('%Y-%m-%d', data_inicio) <= CURRENT_DATE()
AND SAFE.PARSE_DATE('%Y-%m-%d', data_inicio) > DATE_SUB(CURRENT_DATE(), INTERVAL 200 YEAR)
AND SAFE.PARSE_DATE('%Y-%m-%d', data_fim) <= CURRENT_DATE()
AND SAFE.PARSE_DATE('%Y-%m-%d', data_fim) > DATE_SUB(CURRENT_DATE(), INTERVAL 200 YEAR) 
