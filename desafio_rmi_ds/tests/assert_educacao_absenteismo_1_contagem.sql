-- Teste de Contagem
SELECT
  id_escola,
  total_alunos,
  alunos_absenteismo,
  alunos_frequencia_adequada
FROM {{ ref('mart_educacao_absenteismo_1') }}
WHERE total_alunos < 0
  OR alunos_absenteismo < 0
  OR alunos_frequencia_adequada < 0
  OR total_alunos != (alunos_absenteismo + alunos_frequencia_adequada)
