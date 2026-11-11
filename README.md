# Desafio Técnico - Cientista de Dados - Artur Knupp


## Sobre o projeto

Este projeto de engenharia de dados implementa um pipeline utilizando **dbt (Data Build Tool)** e data warehouse **Google BigQuery** com foco na preparação, tranformação e análise dos dados educacionais fornecidos pela Prefeitura do Rio. 

Os dados possuem informações referentes aos alunos, turmas, escolas, avaliações e a frequência escolar. A partir disto, o objetivo é a estruturação dos dados fornecidos aplicando regras de qualidade e transformações com a finalidade de produzir indicadores úteis para auxílio em diversos aspectos a vivência escolar. 

O projeto utiliza uma arquitetura em camadas (**staging**, **intermediate** e **marts**).

## Tecnologias utilizadas

- **Google BigQuery:** Data Warehouse.
- **dbt Core:** Transformação e orquestração dos modelos SQL.
- **SQL:** Linguagem de transformação e consulta.
- **Git/GitHub:** Versionamento do projeto.

## Premissas

O projeto possui duas premissas:

- **Arquivo `~/.dbt/profiles.yml` deve estar devidamente configurado com a conexão do warehouse.** 
- **O dbt já deve estar instalado com uma versão compatível.**
- **Que os dados fonte já estejam carregados no warehouse BigQuery no mesmo formato fonecido.** 
- **As credênciais do banco se encontram configuradas no arquivo **env_variables.sh**, que tem a finalidade expostar variáveis de ambiente como o nome do projeto e o nome do dataset.** 

## Setup
### Clonar o repositório

```bash
git clone git@github.com:arturknupp/desafio-cientista-dados-peqc.git
cd desafio_rmi_ds
```

**Observação:** Não foi possível utilizar o nome recomendado **desafio-rmi-ds** pois o **dbt init** não aceitava hífen.

### Autenticação no Google Cloud

Para autenticação local via OAuth:

```bash
gcloud auth application-default login
```

É necessário possuir as permissões adequadas para consultar as tabelas de origem e criar tabelas no dataset de destino.

### Ajustar credênciais do BigQuery
Como o desenvolvimento foi feito com um banco local, é fundamental que o arquivo `env_variables.sh` seja editando com as credências do ambiente no qual será execultado. 

| Variável | Descrição |
|---|---|
| `DBT_SOURCE_PROJECT` | Projeto onde estão os dados originais. |
| `DBT_SOURCE_DATASET` | Dataset onde estão as tabelas de origem. |
| `DBT_LOCATION` | Região do BigQuery (US ou EU). |

Conteúdo de env_variables.sh:
```bash
    export DBT_SOURCE_PROJECT="nome-do-seu-projeto-bigquery"
    export DBT_SOURCE_DATASET="nome-do-seu-dataset-biquery"

    export DBT_LOCATION="US"
```

Após ajustado, é recomendado execultar o comando a seguir para exportar as variáveis de ambiente antes de prosseguir:

```bash
                                            source env_variables.sh
```

## Execução

Após o arquivo env.variable.sh ser atualizado e referênciado, o proximo passo é utilizar uma das seguintes funções:


- **dbt run**: execulta os modelos nas etapas de staging, intermediate e marts.
- **dbt test**: execulta os testes apenas. 
- **dbt built**: execulta os modelos e aplicam os testes.

Comando recomendado:
```bash
                                                  dbt run
                                                     ou
                                                  dbt built
```

## Arquitetura

O pipeline está organizado em três camadas:

```text
Dados de origem (BigQuery)
          |
          v
      STAGING
          |
          v
    INTERMEDIATE
          |
          v
       MARTS
          |
          v
 Indicadores analíticos
```


Já o projeto possui a seguinte estrutura:
```text
desafio_rmi_ds
├── analyses
├── data
│   ├── rmi-aluno
│   ├── rmi-avaliacao
│   ├── rmi-escola
│   ├── rmi-frequencia
│   ├── rmi-schema.yml
│   └── rmi-turma
├── dbt_project.yml
├── env_variables.sh
├── logs
│   └── dbt.log
├── macros
├── models
│   ├── intermediate
│   │   └── int_educacao_aluno_frequencia.sql
│   ├── marts
│   │   ├── mart_educacao_absenteismo_1.sql
│   │   └── schema.yml
│   ├── sources
│   └── staging
│       ├── schema.yml
│       ├── stg_aluno_limpo.sql
│       ├── stg_avaliacao_limpo.sql
│       ├── stg_escola_limpo.sql
│       ├── stg_frequencia_limpo.sql
│       └── stg_turma_limpo.sql
├── README.md
├── seeds
└── tests
```

### Camada Staging

Camada responsável pela limpeza e padronização dos dados de origem.

Principais operações:

- Remoção de registros sem identificadores essenciais.
- Tratamento de valores nulos e inválidos.
- Padronização de categorias.
- Validação de intervalos numéricos.
- Validação de datas e períodos.
- Tratamento de registros inconsistentes.

Modelos:

| Modelo | Descrição |
|---|---|
| `stg_aluno_limpo` | Limpeza e padronização dos dados dos alunos. |
| `stg_avaliacao_limpo` | Tratamento de avaliações e notas por disciplina. |
| `stg_escola_limpo` | Padronização dos dados das escolas. |
| `stg_frequencia_limpo` | Tratamento dos registros de frequência escolar. |
| `stg_turma_limpo` | Limpeza e padronização dos dados das turmas. |

**Observação:** O sufixo "_limpo" foi escolhido apenas para diferênciar das tabelas originais do banco. Estas tabelas possuem as mesmas informações, porém passaram por um processo de limpeza (eliminação de is_aluno nulos, substituição de valores indesejados na categoria Faixa Etária e etc..).

### Camada Intermediate

Camada responsável por integrar informações provenientes dos modelos de staging e preparar os dados para análises posteriores.

Modelo:

**`int_educacao_aluno_frequencia`**

Premissas:
- Models **stg_aluno_limpo**, **stg_frequencia_limpo** e **stg_escola_limpo** já devem ter sido execultados sem nenhum erro. 

Tipos de Join:
- stg_aluno_limpo **RIGHT JOIN** stg_frequencia_limpo: Como o objetivo final é a avaliação da frequência, é fundamental que todos os registros tenham dados de frequência, assim o stg_aluno_limpo serve para esriquecimento dos dados como faixa etária e bairro de residência do aluno.
- stg_frequencia_limpo **LEFT JOIN** stg_escola_limpo: Utilizamos stg_escola_limpo para enriquecimento do Bairro da Escola. 
- Vale a pena observar que o stg_frequencia_limpo passar por um preprocessamento na própria query antes dop joins. 

Principais operações:

- Integração dos dados de alunos, escolas e frequência.
- Consolidação dos registros por aluno, turma, escola e período.
- Transformação dos registros de frequência em indicadores por disciplina.
- Preparação da granularidade analítica para os modelos de negócio.

### Camada Marts

Camada responsável pela construção dos indicadores analíticos.

Modelo:

**`mart_educacao_absenteismo_1`**

Premissas:
- O model **int_educacao_aluno_frequencia** já deve ter sido execultados sem nenhum erro. 

Objetivo: identificar escolas com maior incidência de alunos cuja frequência média esteja abaixo de 75%.

Indicadores produzidos:

| Indicador | Descrição |
|---|---|
| `total_alunos` | Total de alunos considerados na escola. |
| `alunos_absenteismo` | Alunos com frequência média inferior a 75%. |
| `alunos_frequencia_adequada` | Alunos com frequência média igual ou superior a 75%. |
| `media_frequencia_escola` | Média de frequência dos alunos da escola. |
| `taxa_absenteismo` | Percentual de alunos classificados em situação de absenteísmo. |
| `classificacao_absenteismo` | Classificação do nível de absenteísmo da escola. |

Critérios de classificação:

| Taxa de absenteísmo | Classificação |
|---|---|
| >= 25% | Crítico |
| >= 15% e < 25% | Alto |
| >= 10% e < 15% | Moderado |
| < 10% | Baixo |

**Observação:** os limites acima são critérios analíticos definidos para este projeto, não necessariamente classificações oficiais de órgãos educacionais.


## Testes de qualidade de dados

O projeto utiliza testes nativos do dbt e testes singulares para verificar a integridade dos dados e a consistência das regras de negócio.

### Testes genéricos

Configurados nos arquivos `schema.yml`, os testes genéricos validam a qualidade e a consistência dos dados nas tabelas de staging.

São utilizados quatro tipos de testes:

- `not_null`: verifica se uma coluna não contém valores nulos. É aplicado a campos considerados obrigatórios, como identificadores de alunos, turmas e escolas, além das datas de início e fim dos registros de frequência.
- `unique`: verifica se os valores de uma coluna são únicos, garantindo que não existam identificadores duplicados. É aplicado ao campo `id_escola` da tabela `stg_escola_limpo`.
- `accepted_values`: verifica se os valores de uma coluna pertencem a um conjunto previamente definido. É utilizado para validar categorias como faixas etárias, bimestres e disciplinas, identificando valores fora dos padrões estabelecidos.
- `relationships`: verifica a integridade referencial entre modelos, garantindo que os identificadores de uma tabela correspondam a registros existentes em outra. É aplicado ao campo `id_escola` de `stg_frequencia_limpo`, verificando sua correspondência com `id_escola` em `stg_escola_limpo`.

**Aplicação por modelo:**

- `stg_aluno_limpo`: verifica a presença dos identificadores de aluno e turma e valida os valores permitidos para faixa etária.
- `stg_avaliacao_limpo`: verifica a presença dos identificadores de aluno e turma e valida os valores permitidos para bimestre.
- `stg_escola_limpo`: verifica se o identificador da escola está preenchido e se não existem identificadores duplicados.
- `stg_frequencia_limpo`: verifica o preenchimento dos identificadores de escola, aluno e turma, bem como das datas de início e fim. Também valida os valores permitidos para disciplina e a integridade referencial entre escolas e registros de frequência.

Esses testes permitem identificar problemas de preenchimento, duplicidade, padronização e integridade referencial antes que os dados sejam utilizados nas etapas seguintes do pipeline.

### Testes de singularidade

Implementados por meio de consultas SQL na pasta `tests/`, os testes de singularidade validam regras de negócio e a consistência dos resultados produzidos pelo modelo `mart_educacao_absenteismo_1`.

São utilizados dois testes:

- `assert_educacao_absenteismo_1_contagem`: Verifica a consistência das contagens de alunos por escola. Garante que os valores de total_alunos, alunos_absenteismo e alunos_frequencia_adequada não sejam negativos e que o total de alunos corresponda à soma dos alunos classificados com absenteísmo e os com frequência adequada. Essa validação é relevante serve para assegurar a integridade dos dados após sua agregação, assim evitando divergências nas contagens e garantindo que todos os alunos sejam contabilizados corretamente nas classificações de frequência, evitando distorções nos indicadores e nas análises.

- `assert_educacao_absenteismo_1_classificacao`: Verifica a consistência dos indicadores de frequência e absenteísmo. Garante que a média de frequência escolar e a taxa de absenteísmo estejam dentro dos limites aceitáveis (0% e 100%). Também valida se a taxa de absenteísmo corresponde ao percentual calculado a partir da quantidade de alunos com absenteísmo em relação ao total de alunos. Ela serve para assegurar a confiabilidade dos indicadores educacionais, evitar inconsistências nos percentuais apresentados.

Classificação atribuída à escola está de acordo com os limites definidos (sugestão):
  - **Crítico:** taxa de absenteísmo maior ou igual a 25%.
  - **Alto:** taxa maior ou igual a 15% e menor que 25%.
  - **Moderado:** taxa maior ou igual a 10% e menor que 15%.
  - **Baixo:** taxa inferior a 10%.


## Considerações e limitações



## Melhorias futuras



## Autor

Nome: Artur Knupp
E-mail: knupp@poli.ufrj.br 

