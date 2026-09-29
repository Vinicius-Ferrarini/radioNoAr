# 0003 — Migração de `Choice`, `RadioEvent` e `GameStateLogic`

- **Status:** proposto
- **Data:** 2026-09-29

## Contexto

O loop da v0 é "1 notícia → 3 botões → próxima noite". Ele está inteiro
em `Choice`, `RadioEvent`, `GameStateLogic`, nos 3 `.tres` de
`data/events/`, na cena `radio_show.tscn` e em 4 dos 6 arquivos de teste.

O loop da v1 é "inbox → triagem → escalação em 4 blocos → enquadramento →
ao vivo → manhã → dia". Nada disso cabe em `RadioEvent`: o item precisa de
afirmações conferíveis, canal, remetente, enquadramentos e roteiro. Uma
`Choice` (rótulo + dois deltas) é um caso degenerado de `FramingOption`.

O risco a evitar é o clássico: apagar os testes verdes para "limpar" e
perder a rede de proteção no meio da refatoração.

## Decisão

Substituir, não conviver — mas em duas etapas, e com os testes
**reescritos** em commits identificados, nunca apagados em silêncio.

1. **Até o M9, a v0 fica intocada e verde.** Os módulos v1 nascem ao lado
   (`BroadcastItem`, `FramingOption`, `RunState`, `NightCycle`), com
   testes próprios. `radio_show.tscn` continua jogável. A suíte só cresce.
2. **No M10** (fatia vertical pronta), a v0 é removida num commit único e
   revisável, "remove o loop v0 substituído pela fatia vertical":
   - apagados: `scripts/core/choice.gd`, `scripts/core/radio_event.gd`,
     `scripts/core/game_state_logic.gd`, `data/events/event_0*.tres`;
   - reescritos: `test_choice_application.gd` e `test_game_state_flow.gd`
     tornam-se `test_run_state.gd` e `test_night_cycle.gd`, cobrindo as
     mesmas garantias (clamp de medidor, avanço de noite, histórico);
     `test_events_data.gd` torna-se `test_night_definitions.gd`;
     `test_full_playthroughs.gd` torna-se `test_night_one_run.gd`.
   - `test_ending_resolver.gd` sobrevive até o **M12**, quando a API v2
     entra e ele é reescrito com os limiares de país × pessoal.
3. **Cobertura não regride:** o commit de remoção precisa deixar a suíte
   com número de asserts maior ou igual ao anterior. Se alguma garantia da
   v0 não tiver equivalente na v1, ela fica escrita aqui como perda
   consciente — não desaparece sem registro.

`Choice.Stance` (TRUTH / CROWD_PLEASING / ATTACK) é absorvido por
`FramingOption.Kind`: TRUTH → `TRUTH`, CROWD_PLEASING → `SOFTEN` ou
`AS_RECEIVED`, ATTACK → `INFLAME`. Os três `RadioEvent` existentes viram
material de conteúdo para o M13 (o texto é bom, o formato não serve).

## Alternativas consideradas

- **Fazer a v1 estender a v0** (`BroadcastItem extends RadioEvent`).
  Rejeitado: herança de Resource para reaproveitar quatro campos de String
  amarra o modelo novo a um formato que vai morrer.
- **Manter os dois loops jogáveis** (menu com "modo clássico").
  Rejeitado: dobra a superfície de manutenção de um protótipo descartado.
- **Remover a v0 já no M5**, para não carregar peso morto. Rejeitado:
  deixaria o projeto sem nada jogável por 5 marcos, e é justamente a
  suíte v0 que detecta se o autoload quebrou durante a refatoração.

## Consequências

- Entre o M5 e o M9 o repositório tem dois modelos de dados ao mesmo
  tempo. Isso é explícito e datado, não acidente: quem lê o SPEC §1 vê
  "v0, até o M10".
- O commit do M10 é grande em linhas removidas e pequeno em risco, porque
  cada teste reescrito nasce verde antes da remoção.
- `GameState` muda de assinatura pública no M10 (sinais novos,
  `power_changed` sai).

**Correção registrada em 2026-09-29 (durante o M8):** este ADR previa que
`radio_show.tscn` seria reconstruído no M8, "então não há cena dependendo
da API velha nesse momento". Errado. O M8 constrói a triagem e a
escalação **na cena da mesa** (`studio_desk.tscn`), e `radio_show.tscn`
continua vivo e jogável com a API v0 até o M10 — inclusive com os offsets
reescalados no M7 para o viewport novo. Na prática isso significa que o
autoload `GameState` carrega **as duas APIs ao mesmo tempo** entre o M8 e
o M10: os sinais e métodos v0 (`power_changed`, `apply_choice`,
`get_current_event`) e os v1 (`phase_changed`, `place_item`,
`link_claim`…). A remoção da metade v0 continua marcada para o M10, no
mesmo commit que apaga `Choice`/`RadioEvent`/`GameStateLogic`.
