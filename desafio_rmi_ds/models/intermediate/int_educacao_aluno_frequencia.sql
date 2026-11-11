{{
    config(
        materialized='table'
    )
}}

WITH dt_frequencia AS (
SELECT 
  id_aluno,
  id_turma,
  id_escola,
  data_inicio,
  data_fim, 
  MAX(CASE WHEN disciplina = 'disciplina_1' THEN frequencia
  ELSE 0 END) AS freq_disciplina_1,
  MAX(CASE WHEN disciplina = 'disciplina_2' THEN frequencia
  ELSE 0 END) AS freq_disciplina_2,
  MAX(CASE WHEN disciplina = 'disciplina_3' THEN frequencia
  ELSE 0 END) AS freq_disciplina_3,
  MAX(CASE WHEN disciplina = 'disciplina_4' THEN frequencia
  ELSE 0 END) AS freq_disciplina_4
FROM {{ ref('stg_frequencia_limpo') }}
GROUP BY 
  id_aluno,
  id_turma,
  id_escola,
  data_inicio,
  data_fim 
)
SELECT
  COALESCE(frequencia.id_aluno, aluno.id_aluno) id_aluno,
  COALESCE(frequencia.id_turma, aluno.id_turma) id_turma, 
  COALESCE(frequencia.id_escola,escola.id_escola) id_escola,
  COALESCE(faixa_etaria, 'Desconhecida') faixa_etaria,
  aluno.bairro bairro_do_aluno,
  escola.bairro bairro_da_escola,
  data_inicio data_inicio_turma,
  data_fim data_fim_turma, 
  freq_disciplina_1,
  freq_disciplina_2,
  freq_disciplina_3,
  freq_disciplina_4
FROM {{ ref('stg_aluno_limpo') }} aluno
RIGHT JOIN dt_frequencia frequencia 
ON aluno.id_aluno=frequencia.id_aluno and aluno.id_turma=frequencia.id_turma
LEFT JOIN {{ ref('stg_escola_limpo') }} escola
ON frequencia.id_escola=escola.id_escola
