# No Ar — Roadmap

Status dos marcos. Critérios de aceite completos em `docs/SPEC.md` §9.
Um marco só é "concluído" com a suíte GUT inteira verde headless.

Atualizado em: 2026-09-29 (sessão de planejamento da v1).

## Legenda

✅ concluído · 🔵 em andamento · ⬜ não começado · ⏸ bloqueado por decisão

## v0 — protótipo jogável (concluído)

| Marco | Entrega | Status |
|---|---|---|
| M0 | Projeto Godot + GUT rodando headless | ✅ |
| M1 | `Choice`, `RadioEvent`, `GameStateLogic`, `EndingResolver` + testes | ✅ |
| M2 | Autoload `GameState` + cenas `RadioShow`/`Ending` | ✅ |
| M3 | Theme, Courier Prime, transições, barra animada | ✅ |

Linha de base em 2026-09-29: **19 testes, 19 passando, 76 asserts, 0,93 s.**

O M4 antigo ("eventos reais substituindo os de teste") foi absorvido pelo
M13: o formato de conteúdo muda com o `NightDefinition`, e escrever
conteúdo no formato v0 agora seria trabalho perdido (ADR 0003).

## v1 — o jogo descrito em `docs/GAME_DESIGN.md`

| Marco | Entrega | Status | Depende de |
|---|---|---|---|
| M4 | Casa em ordem: branch, `.gitignore`, `.godot/` fora do índice, ADRs, ROADMAP | 🔵 ¹ | — |
| M5 | Dados v1 + `Notebook` + `Validator` (TDD) | ✅ ² | M4 |
| M6 | `Meters`, `ProgramRundown`, `ConsequenceQueue`, `RunState`, `NightCycle` | ✅ ³ | M5 |
| M7 | Pipeline de pixel art + manifesto + mesa estática + resolução/escala | ✅ ⁴ | M4 |
| M8 | Triagem e escalação: closes, marcar e cruzar, arrastar para os 4 blocos | ⬜ | M6, M7 |
| M9 | Ao vivo: `LiveBroadcast`, teleprompter, ar morto, palavras proibidas, improviso, ligação | ⬜ | M6 |
| M10 | Manhã + **fatia vertical: noite 1 de ponta a ponta**; remoção da v0 | ⬜ | M8, M9 |
| M11 | Fase de dia: transmissor, sinal, equipe, dinheiro | ⬜ | M10 |
| M12 | Finais país × pessoal (`EndingResolver` v2) | ⬜ | M10 + nº de noites |
| M13 | Conteúdo das noites até o referendo + corte da internet | ⬜ | M12 |
| M14 | Som e polimento: trilha como sinal, ruído de dial, esvair da paleta | ⬜ | M13 |

¹ M4 executado em 2026-09-29: `.gitignore` na raiz, `.godot/` removido do
índice (171 arquivos), `docs/adr/` e `docs/ROADMAP.md` criados,
`CLAUDE.md` atualizado, suíte 19/19 verde. **Nada foi commitado** — por
pedido do dono do projeto, as mudanças estão na árvore de trabalho e no
índice. Falta também trocar a branch padrão para `master` no GitHub e
descartar `main`, passo manual descrito no ADR 0001.

² M5 concluído em 2026-09-29: 6 Resources em `scripts/core/data/`,
`Notebook` e `Validator` em `scripts/core/`, conteúdo da noite 1
(`data/nights/night_01.tres`, 7 entradas de caderno, 10 consequências).
Suíte **54/54, 230 asserts**. Os 19 testes da v0 continuam verdes.

³ M6 concluído em 2026-09-29: `Meters`, `RadioResources`,
`ProgramRundown`, `ConsequenceQueue`, `RunState`, `NightCycle` e
`ContentLibrary` em `scripts/core/`; `OrderRule`/`OrderRuleSet` em
`scripts/core/data/`; `data/rules/order_rules.tres` com 4 regras de
adjacência. Suíte **141/141, 619 asserts**. A fase `LIVE` é passagem
direta até o M9.

⁴ M7 concluído em 2026-09-29: `tools/pixelart/` (paleta, builder,
gerador, previsualizador ASCII) + 12 definições de sprite; 12 PNGs e
`manifest.json` versionados em `assets/sprites/`; `scenes/studio_desk.tscn`
em 320×180; `project.godot` com escala inteira e filtro nearest; Theme
reescalado (fonte 20/28 → 7/10). Suíte **161/161, 13 178 asserts**
(a maioria é a varredura pixel a pixel da paleta).
Duas decorrências registradas: a **cena principal passou a ser a mesa**
(`studio_desk.tscn`), e as cenas da v0 tiveram seus offsets reescalados
por 320/1152 para continuarem jogáveis até o M10, como o ADR 0003
prometeu.

M7 não depende tecnicamente de M5/M6 — a pixel art e a lógica não se
cruzam. Ficou decidido rodar a lógica primeiro (M5 → M6) e só então o M7:
o custo é ficar dois marcos sem novidade na tela.

## Ordem sugerida de trabalho

1. **M4** destrava tudo (uma decisão sua, depois meia hora de trabalho).
2. **M5 → M6** constroem a lógica testável sem nenhuma cena.
3. **M7** dá o primeiro visual novo.
4. **M8 → M9 → M10** fecham a fatia vertical — é aqui que o jogo passa a
   ser o jogo do design.
5. **M11 → M14** expandem sobre uma base já provada.

## Riscos conhecidos

| Risco | Mitigação |
|---|---|
| O ao vivo (M9) é a mecânica mais complexa e a mais fácil de ficar chata | Tempo injetado (ADR 0007) permite iterar nos números sem retestar à mão |
| 320×180 pode não caber os closes de texto | ADR 0005 prevê a troca para 480×270 como substituição de ADR, mudança pequena |
| Conteúdo de ~30 noites é o maior volume de trabalho do projeto | Teste de sanidade de conteúdo (ADR 0009) evita conteúdo quebrado silencioso |
| Dois modelos de dados convivendo entre M5 e M9 | Prazo de remoção fixado no ADR 0003 (M10), não indefinido |

## Decisões tomadas (2026-09-29)

| Decisão | Onde está registrada |
|---|---|
| Branch principal: `master`; `main` descartada | ADR 0001 (aceito) |
| Medidores: seis eixos, `power` → `alignment` | ADR 0002 (aceito) |
| Campanha de 21 noites até o referendo | GAME_DESIGN §1, SPEC §4.8 |
| Ordem depois do M4: lógica (M5 → M6) antes da arte (M7) | esta tabela |

## Decisões pendentes

- **ADR 0003** (remoção do loop v0 no M10) aguarda a aprovação do plano.
- Noite do corte da internet, derrota antecipada e teto da cota de
  propaganda: `docs/GAME_DESIGN.md` §14. Nenhuma delas bloqueia o M4–M10.
