--consistência na clasificação
SELECT
  id_escola,
  total_alunos,
  media_frequencia_escola,
  taxa_absenteismo,
  classificacao_absenteismo
FROM {{ ref('mart_educacao_absenteismo_1') }}
WHERE media_frequencia_escola < 0
  OR media_frequencia_escola > 100
  OR taxa_absenteismo < 0
  OR taxa_absenteismo > 100
  OR ABS(taxa_absenteismo - ROUND(SAFE_DIVIDE(alunos_absenteismo, total_alunos) * 100,2)) > 0.01
  OR classificacao_absenteismo != 
    CASE
      WHEN taxa_absenteismo>=25 THEN 'Crítico'
      WHEN taxa_absenteismo>=15 THEN 'Alto'
      WHEN taxa_absenteismo>=10 THEN 'Moderado'
     ELSE 'Baixo'
     END
