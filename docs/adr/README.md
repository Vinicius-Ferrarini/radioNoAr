# Registros de Decisão de Arquitetura (ADR)

Um arquivo por decisão, numeração sequencial, nome
`NNNN-titulo-curto.md`. Formato: Status · Contexto · Decisão ·
Alternativas consideradas · Consequências.

Status possíveis: **proposto** (aguardando decisão), **aceito**,
**substituído por NNNN**. Um ADR aceito não é editado quando a decisão
muda: cria-se outro que o substitui, e o antigo passa a "substituído".

Crie um ADR sempre que decidir arquitetura, ferramenta, formato de dados,
escopo, ou ao reverter uma decisão anterior.

## Índice

| # | Título | Status |
|---|---|---|
| [0001](0001-branch-principal-e-higiene-do-repositorio.md) | Branch principal e higiene do repositório | aceito |
| [0002](0002-reconciliacao-dos-medidores.md) | Reconciliação dos medidores (v0 × v1) | aceito |
| [0003](0003-migracao-de-choice-radioevent-e-gamestatelogic.md) | Migração de `Choice`, `RadioEvent` e `GameStateLogic` | aceito e executado (M10) |
| [0004](0004-pipeline-de-pixel-art.md) | Pipeline de pixel art gerada por script | aceito |
| [0005](0005-resolucao-base-e-escala-inteira.md) | Resolução base, escala inteira e filtro de textura | aceito |
| [0006](0006-texto-hibrido-nos-documentos-em-close.md) | Texto híbrido nos documentos em close | aceito |
| [0007](0007-tempo-e-rng-injetados-na-logica-pura.md) | Tempo e RNG injetados; eventos drenados | aceito |
| [0008](0008-degradacao-da-paleta-conforme-o-cerco.md) | Como a cor se esvai conforme o cerco aperta | aceito |
| [0009](0009-formato-do-conteudo-das-noites.md) | Formato do conteúdo das noites | aceito |
| [0010](0010-a-mesa-e-a-casa.md) | A mesa é a casa: closes diegéticos no lugar do painel com abas | aceito |
| [0011](0011-radio-viva-e-abertura-gradual.md) | Rádio viva e abertura gradual | aceito e implementado |
| [0012](0012-a-mesa-respira.md) | A mesa respira: leito de som e movimento | aceito e implementado |
| [0013](0013-a-conversa-e-a-decisao.md) | A conversa é a decisão; a cidade é o medidor | aceito (Fase 1 em execução) |

Decisões do designer em 2026-09-29, fora de ADR (registradas em
`docs/GAME_DESIGN.md` e `docs/SPEC.md`): campanha de **21 noites** até o
referendo.
