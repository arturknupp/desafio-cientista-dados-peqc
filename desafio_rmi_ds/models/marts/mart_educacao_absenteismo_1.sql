{{
    config(
        materialized='table'
    )
}}


WITH frequencia_por_aluno AS (
    SELECT
        id_aluno,
        id_escola,
        bairro_da_escola AS bairro_da_escola,
        AVG(frequencia_disciplina) AS media_frequencia
    FROM {{ ref('int_educacao_aluno_frequencia') }}
    CROSS JOIN UNNEST([
        freq_disciplina_1,
        freq_disciplina_2,
        freq_disciplina_3,
        freq_disciplina_4
    ]) AS frequencia_disciplina
    WHERE id_aluno IS NOT NULL
    GROUP BY
        id_aluno,
        id_escola,
        bairro_da_escola
), indicadores_escola AS (
    SELECT
        id_escola,
        bairro_da_escola,
        COUNT(*) AS total_alunos,
        COUNTIF(media_frequencia < 75) AS alunos_absenteismo,
        COUNTIF(media_frequencia >= 75) AS alunos_frequencia_adequada,
        ROUND(AVG(media_frequencia), 2) AS media_frequencia_escola,
        ROUND(SAFE_DIVIDE(COUNTIF(media_frequencia < 75),COUNT(*)) * 100,2) AS taxa_absenteismo
    FROM frequencia_por_aluno
    GROUP BY
        id_escola,
        bairro_da_escola
)
SELECT
    id_escola,
    bairro_da_escola,
    total_alunos,
    alunos_absenteismo,
    alunos_frequencia_adequada,
    media_frequencia_escola,
    taxa_absenteismo,
    CASE WHEN taxa_absenteismo >= 25 THEN 'Crítico'
               WHEN taxa_absenteismo >= 15 THEN 'Alto'
               WHEN taxa_absenteismo >= 10 THEN 'Moderado'
    ELSE 'Baixo' END AS classificacao_absenteismo
FROM indicadores_escola
ORDER BY
    taxa_absenteismo DESC,
    alunos_absenteismo DESC
