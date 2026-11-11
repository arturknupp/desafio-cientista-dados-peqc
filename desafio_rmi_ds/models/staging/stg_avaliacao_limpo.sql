{{
    config(
        materialized='table'
    )
}}

SELECT 
  id_aluno,
  id_turma,
  CASE WHEN frequencia > 100.0 THEN 100.0
       WHEN frequencia < 0.0 THEN 0.0
  ELSE frequencia END frequencia, 
  CASE WHEN bimestre IS NULL THEN bimestre
       WHEN bimestre NOT IN ('1','2','3','4') THEN 'Desconhecido'
  ELSE bimestre END bimestre,
  CASE WHEN disciplina_1 > 10.0 THEN 10.0
       WHEN disciplina_1 < 0.0 THEN 0.0
  ELSE disciplina_1 END disciplina_1, 
  CASE WHEN disciplina_2 > 10.0 THEN 10.0
       WHEN disciplina_2 < 0.0 THEN 0.0
  ELSE disciplina_2 END disciplina_2, 
  CASE WHEN disciplina_3 > 10.0 THEN 10.0
       WHEN disciplina_3 < 0.0 THEN 0.0
  ELSE disciplina_3 END disciplina_3,
  CASE WHEN disciplina_4 > 10.0 THEN 10.0
       WHEN disciplina_4 < 0.0 THEN 0.0
  ELSE disciplina_4 END disciplina_4 
 FROM {{ source('educacao_raw', 'stg_avaliacao') }} 
 WHERE id_aluno is not null
