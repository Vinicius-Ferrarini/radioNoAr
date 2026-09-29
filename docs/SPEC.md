# No Ar — Especificação Técnica (SDD)

Este documento é a fonte de verdade técnica. Código deve implementar o
que está aqui; se um comportamento não está descrito, pare e proponha uma
adição a este arquivo antes de implementar.

- Design: `docs/GAME_DESIGN.md`
- Decisões de arquitetura: `docs/adr/`
- Status dos marcos: `docs/ROADMAP.md`

Seções marcadas **(proposto)** dependem de uma decisão registrada em ADR
ainda não aceita — não implemente antes da decisão.

Decisões já tomadas que atravessam todo o documento: branch principal
`master` (ADR 0001), medidores no modelo de seis eixos (ADR 0002),
campanha de **21 noites** até o referendo.

---

## 1. Estado atual (v0, marcos M0–M3 concluídos)

Implementado e verde (19 testes GUT). Continua valendo até o marco que
explicitamente o substituir (ver ADR 0003).

### 1.1 Dados v0

**Choice** (`scripts/core/choice.gd`, extends Resource)
`id: String` · `label: String` · `response_text: String` ·
`power_delta: int` · `integrity_delta: int` ·
`stance: enum { TRUTH, CROWD_PLEASING, ATTACK }`

**RadioEvent** (`scripts/core/radio_event.gd`, extends Resource)
`id: String` · `night: int` · `headline: String` · `body: String` ·
`choices: Array[Choice]` (sempre 3)

### 1.2 Lógica v0

**GameStateLogic** (`scripts/core/game_state_logic.gd`, RefCounted)
Estado: `power = 50`, `integrity = 50`, `inconsistency = 0`,
`current_night = 1`, `history: Array[Choice]`.
`apply_choice(choice)` soma os deltas com clamp 0–100, empilha em
`history`, incrementa `current_night`. `is_finished(total_nights)`.
`resolve_ending()` delega para `EndingResolver.resolve(power)`.

**EndingResolver** (`scripts/core/ending_resolver.gd`, RefCounted,
estático) — `resolve(power: int) -> String`: `> 65` → `"repressao"`,
`< 35` → `"reforma"`, senão `"cinza"`.

### 1.3 Autoload v0

**GameState** (`scripts/game_state.gd`) — sinais `power_changed`,
`night_advanced`, `game_ended`; métodos `load_events`,
`get_current_event`, `apply_choice`, `reset_run`, `get_power`,
`get_current_night`, `get_last_ending_id`. Não decide nada: delega para
`GameStateLogic`/`EndingResolver` e traduz em sinais.

### 1.4 Apresentação v0 (M3)

Courier Prime (SIL OFL) em `res://assets/fonts/`; Regular 20 para corpo,
Bold 28 para headline. `res://theme/theme.tres` com fundo `#12100e`,
texto `#e8e4da`, destaque `#b23a2f`, `StyleBoxFlat` de cantos retos.
Barra de Poder animada por `Tween` (0.35 s, TRANS_SINE, EASE_OUT).
Transições por `ColorRect` "FadeOverlay" (0.3 s). Nenhuma lógica de
decisão nos scripts de cena.

---

## 2. Convenções (valem para todo código novo)

- Godot 4.7.2 (build Mono), GDScript com **tipos estáticos em toda
  assinatura e variável de membro**.
- Três camadas, sem exceção:
  1. **Dados** — `Resource` em `scripts/core/data/`. Só `@export` e
     constantes; nunca comportamento.
  2. **Lógica pura** — `RefCounted` em `scripts/core/`. Não conhece
     `Node`, `SceneTree`, `Time`, `Timer`, `Input` nem `OS`.
  3. **Apresentação** — cenas em `scenes/`. Só escutam sinais do
     autoload `GameState` e chamam métodos dele. Nunca guardam estado de
     jogo, nunca decidem regra.
- UI 100% em nós `Control` + `Theme`. **Nunca `_draw()`.** Tudo deve
  ficar editável visualmente no editor.
- **Tempo injetado:** a lógica pura recebe `tick(delta: float)`. Só o
  autoload tem `_process` (ADR 0007).
- **RNG injetado:** todo sorteio recebe um `RandomNumberGenerator` com
  seed vinda de fora. Nenhuma chamada a `randi()`/`randf()` global.
- **Eventos sem sinais na lógica pura:** módulos puros acumulam
  ocorrências e as entregam por `drain_events() -> Array[Dictionary]`; o
  autoload é quem transforma isso em sinais (ADR 0007).
- Ids são `String` em `snake_case`. `Dictionary` de deltas usa as
  constantes de `Meters` como chave — nunca literais soltos.
- Nomes de arquivo em `snake_case`, um `class_name` por arquivo.
- Testes em `tests/unit/`, um arquivo por módulo, nomeados
  `test_<modulo>.gd`.

---

## 3. Modelo de dados v1 (Resources, `scripts/core/data/`)

### ItemClaim — `item_claim.gd`
Uma afirmação conferível dentro de um item.

| Campo | Tipo | Observação |
|---|---|---|
| `id` | String | único dentro do item |
| `field` | `enum Field { PLACE, DATE, NAME, NUMBER, STAMP, SEAL, HANDWRITING, PHOTO, SENDER_HISTORY, CODE }` | o que se confere |
| `key` | String | chave normalizada, ex. `"rua_aurora"` |
| `excerpt` | String | trecho mostrado ao jogador |
| `contradicted_by` | `Array[int]` | valores de `NotebookEntry.Category` que contradizem esta afirmação |

`contradicted_by` é `Array[int]` porque `@export` não aceita array tipado
por enum de outra classe; os valores são sempre de
`NotebookEntry.Category`.

### NotebookEntry — `notebook_entry.gd`

| Campo | Tipo |
|---|---|
| `id` | String |
| `category` | `enum Category { FORBIDDEN_WORD, EVACUATED_AREA, CURFEW, KNOWN_INFORMANT, DETAINED, DISAPPEARED, LIAR_SENDER, RESISTANCE_CODE }` |
| `key` | String (casa com `ItemClaim.key`) |
| `text` | String (como aparece no caderno) |
| `night_added` | int |

### FramingOption — `framing_option.gd`

| Campo | Tipo | Observação |
|---|---|---|
| `kind` | `enum Kind { AS_RECEIVED, TRUTH, SOFTEN, INFLAME, IRONY, DISCARD }` | |
| `script_id` | String | roteiro de teleprompter usado no ar |
| `immediate_deltas` | Dictionary | `meter_id -> int`; **só medidores visíveis reagem ao vivo** |
| `consequence_ids` | `Array[String]` | `ConsequenceEffect` agendados para a manhã |

`IRONY` só é válido para itens de tipo `PROPAGANDA` (invariante testada).

### BroadcastItem — `broadcast_item.gd`

| Campo | Tipo | Observação |
|---|---|---|
| `id` | String | |
| `type` | `enum ItemType { BRIBE, VENDOR, REVENGE, SPOTLIGHT, HELP_REQUEST, PROPAGANDA }` | |
| `channel` | `enum Channel { PHONE, LETTER, CALL, OFFICIAL }` | define o close usado na UI |
| `sender_id` | String | |
| `headline` | String | |
| `body` | String | o texto como chegou |
| `claims` | `Array[ItemClaim]` | |
| `framings` | `Array[FramingOption]` | enquadramentos permitidos |
| `counts_for_quota` | bool | true nos itens oficiais |
| `is_fraudulent` | bool | **verdade de bastidor**; nunca exibida, nunca lida pelo `Validator` |

### ConsequenceEffect — `consequence_effect.gd`

| Campo | Tipo | Observação |
|---|---|---|
| `id` | String | |
| `delay_nights` | int = 1 | mínimo 1: nunca há consequência na mesma noite |
| `condition` | `enum Condition { ALWAYS, FRAUD_AIRED, FRAUD_CAUGHT }` | |
| `meter_deltas` | Dictionary | `meter_id -> int` |
| `morning_headline` | String | |
| `morning_letter` | String | |
| `notebook_entry_ids` | `Array[String]` | entradas que a manhã acrescenta ao caderno |
| `flags_set` | `Array[String]` | marcas narrativas para o `EndingResolver` |

### Roteiro do teleprompter

**ForbiddenWordSlot** — `forbidden_word_slot.gd`:
`word: String` · `char_start: int` · `approved_synonym: String`

**ImprovOption** — `improv_option.gd`:
`id: String` · `text: String` · `framing_kind: int` (`FramingOption.Kind`)
· `immediate_deltas: Dictionary` · `consequence_ids: Array[String]`

**ImprovPoint** — `improv_point.gd`:
`id: String` · `time_limit_seconds: float` · `options: Array[ImprovOption]`
— **o índice 0 é a opção padrão**, usada quando o tempo estoura.

**ScriptLine** — `script_line.gd`:
`text: String` · `read_seconds: float` ·
`forbidden_slots: Array[ForbiddenWordSlot]` ·
`improv_point: ImprovPoint` (null = sem improviso nesta linha)

**BroadcastScript** — `broadcast_script.gd`:
`id: String` · `lines: Array[ScriptLine]`

### OrderRule — `order_rule.gd`
Efeito de adjacência entre blocos do programa.

`id: String` · `previous_type: int` · `next_type: int` (ambos
`BroadcastItem.ItemType`; `OrderRule.ANY_TYPE`, que vale `-1`, casa com
qualquer tipo) · `meter_deltas: Dictionary` ·
`consequence_ids: Array[String]` · `description: String`

Regras vivem em `data/rules/order_rules.tres` — nunca no código.
Exemplo canônico: `previous_type = REVENGE`, `next_type = PROPAGANDA`
("propaganda depois de denúncia soa como ironia").

### OrderRuleSet — `order_rule_set.gd`
Contêiner para as `OrderRule` poderem morar num `.tres` só:
`rules: Array[OrderRule]`. Existe porque um arquivo de recurso precisa de
um recurso raiz; não tem comportamento.

### NightDefinition — `night_definition.gd`

| Campo | Tipo |
|---|---|
| `night` | int |
| `era` | `enum Era { PHONE, LETTERS }` |
| `inbox` | `Array[BroadcastItem]` (mais itens do que os 4 blocos) |
| `propaganda_quota` | int |
| `new_notebook_entries` | `Array[NotebookEntry]` |

Conteúdo em `data/nights/night_NN.tres` (ADR 0009).

---

## 4. Lógica pura v1 (`scripts/core/`)

### 4.1 Meters — `meters.gd`

```gdscript
class_name Meters extends RefCounted

const AUDIENCE_TRUST := "audience_trust"
const STREET_HEAT := "street_heat"
const REGIME_ATTENTION := "regime_attention"
const ALIGNMENT := "alignment"          # 0 = povo, 100 = governo
const INTEGRITY := "integrity"
const INCONSISTENCY := "inconsistency"  # contador, sem teto

func get_value(id: String) -> int
func apply(id: String, delta: int) -> int          # devolve o novo valor
func apply_all(deltas: Dictionary) -> Dictionary   # id -> novo valor
func snapshot() -> Dictionary
static func is_hidden(id: String) -> bool
static func all_ids() -> PackedStringArray
```

- Valores iniciais: `AUDIENCE_TRUST = 50`, `STREET_HEAT = 30`,
  `REGIME_ATTENTION = 10`, `ALIGNMENT = 50`, `INTEGRITY = 50`,
  `INCONSISTENCY = 0`.
- Clamp 0–100 em todos, exceto `INCONSISTENCY` (clamp inferior 0, sem
  teto).
- Escondidos: `REGIME_ATTENTION`, `INTEGRITY`, `INCONSISTENCY`.
- `apply` com id desconhecido não escreve nada e devolve 0, em silêncio.
  Quem pega o erro é um teste de conteúdo: toda chave de `meter_deltas`
  em `data/` precisa estar em `Meters.all_ids()`. Um `push_error` aqui
  só faria barulho em tempo de execução por um erro que é de dados, e
  um `assert` derrubaria a suíte em vez de reprovar um teste.
- `has_meter(id) -> bool` existe para quem precisa validar antes.

Modelo decidido no ADR 0002 (Opção A, aceito).

### 4.2 Notebook — `notebook.gd`

```gdscript
func add_entry(entry: NotebookEntry) -> bool        # false se id repetido
func add_entries(entries: Array[NotebookEntry]) -> int
func all_entries() -> Array[NotebookEntry]
func entries_in_category(category: int) -> Array[NotebookEntry]
func entries_for_key(key: String) -> Array[NotebookEntry]
func find_entry(id: String) -> NotebookEntry        # null se não existe
func forbidden_words() -> PackedStringArray
```

O caderno só cresce: não existe método de remoção.

### 4.3 Validator — `validator.gd`

```gdscript
enum Result { UNRELATED, CONSISTENT, CONTRADICTION }

func _init(notebook: Notebook) -> void
static func evaluate(claim: ItemClaim, entry: NotebookEntry) -> Result
func link(item: BroadcastItem, claim_id: String, entry_id: String) -> Result
func links_for(item_id: String) -> Array[Dictionary]  # {claim_id, entry_id, result}
func contradictions_for(item_id: String) -> Array[String]  # claim_ids
func set_suspicious(item_id: String, value: bool) -> void
func is_suspicious(item_id: String) -> bool
```

`evaluate` é total e pura, nesta ordem:
1. `claim` ou `entry` nulo → `UNRELATED`
2. `claim.key != entry.key` → `UNRELATED`
3. `entry.category` em `claim.contradicted_by` → `CONTRADICTION`
4. senão → `CONSISTENT`

`link` com `claim_id` inexistente no item, ou `entry_id` inexistente no
caderno, devolve `UNRELATED` e **não registra nada** — ligação inválida
não vira histórico. Religar o mesmo par `(claim_id, entry_id)` não
duplica o registro.

**Invariante:** o `Validator` nunca lê `BroadcastItem.is_fraudulent`.
Achar contradição não prova fraude; não achar não prova verdade. Quem
cruza detecção com verdade é a fase de manhã, via
`ConsequenceEffect.condition`.

### 4.4 ProgramRundown — `program_rundown.gd`

```gdscript
const BLOCK_COUNT := 4
enum PlaceResult { OK, INVALID_BLOCK, BLOCK_TAKEN, ITEM_ALREADY_PLACED, FRAMING_NOT_ALLOWED }

func _init(propaganda_quota: int, order_rules: Array[OrderRule]) -> void
func place(item: BroadcastItem, block_index: int) -> PlaceResult
func move(from_index: int, to_index: int) -> PlaceResult
func clear_block(block_index: int) -> void
func item_at(block_index: int) -> BroadcastItem
func set_framing(block_index: int, kind: int) -> PlaceResult
func framing_at(block_index: int) -> int            # -1 se não escolhido
func filled_blocks() -> int
func quota_required() -> int
func quota_filled() -> int                          # itens com counts_for_quota
func quota_met() -> bool
func is_ready() -> bool                             # 4 blocos com item e enquadramento
func aired_items() -> Array[BroadcastItem]          # os que realmente vão ao ar
func order_effects() -> Array[OrderRule]            # regras casadas pela ordem atual
```

- `move` para um bloco ocupado **troca** os dois itens; o enquadramento
  acompanha o item, não o bloco.
- `move` de um bloco vazio, ou com índice fora de 0–3, é
  `INVALID_BLOCK`.
- `set_framing` recusa um `kind` que não esteja em `item.framings`, e
  recusa bloco vazio. `framing_at` devolve `-1` enquanto não escolhido.
- **`DISCARD` não vai ao ar.** Um bloco descartado não entra em
  `aired_items()`, não conta para `quota_filled()` e não forma
  adjacência em `order_effects()` — mas continua ocupando o bloco, que é
  o custo de descartar.
- Cota não cumprida **não** impede `is_ready()`: recusar a cota é uma
  escolha do jogador, paga em `REGIME_ATTENTION` na manhã seguinte.
- `order_effects` percorre os pares de blocos consecutivos que vão ao ar
  e devolve cada `OrderRule` casada, na ordem dos blocos.

### 4.5 ConsequenceQueue — `consequence_queue.gd`

```gdscript
func schedule(effect: ConsequenceEffect, current_night: int) -> int  # noite de vencimento
func peek_due(night: int) -> Array[ConsequenceEffect]
func pop_due(night: int) -> Array[ConsequenceEffect]
func pending_count() -> int
func clear() -> void
```

- Vencimento = `current_night + max(1, effect.delay_nights)`.
- `pop_due(n)` devolve tudo com vencimento `<= n` e remove da fila, na
  ordem de agendamento.
- **Invariante:** nada agendado na noite *n* aparece em `pop_due(n)`.

### 4.6 LiveBroadcast — `live_broadcast.gd`

Máquina de estados do ao vivo, com tempo injetado.

```gdscript
enum State { READY, ON_AIR, DEAD_AIR, IMPROV, FINISHED }
enum EventKind {
    LINE_ADVANCED, DEAD_AIR_STARTED, DEAD_AIR_ENDED,
    FORBIDDEN_WORD_AIRED, WORD_REPLACED,
    IMPROV_REQUESTED, IMPROV_RESOLVED, IMPROV_TIMEOUT,
    CALL_TRANSCRIPT, CALL_AIRED, CALL_CUT, BLOCK_FINISHED,
}

const DEAD_AIR_TRUST_PER_SECOND := 2.0
const CALL_DELAY_SECONDS := 7.0

func _init(script: BroadcastScript, rng: RandomNumberGenerator) -> void
func set_mic_held(held: bool) -> void
func tick(delta: float) -> void
func replace_word(slot_index: int) -> bool
func choose_improv(option_index: int) -> bool
func queue_call(transcript: String) -> void
func cut_call() -> bool
func state() -> State
func line_index() -> int
func line_progress() -> float            # 0..1 na linha atual
func dead_air_seconds() -> float
func infractions() -> Array[String]      # palavras proibidas que foram ao ar
func audience_delta() -> int
func chosen_improvs() -> Array[String]   # ids de ImprovOption
func drain_events() -> Array[Dictionary] # {kind, ...}; esvazia a fila
func is_finished() -> bool
```

Regras (cada item é um teste):

1. `READY` → `ON_AIR` em `set_mic_held(true)`. `tick` em `READY` não faz
   nada.
2. Em `ON_AIR`, `tick(delta)` soma `delta` ao tempo da linha atual. Ao
   atingir `read_seconds`: cada `ForbiddenWordSlot` não substituído entra
   em `infractions()` e emite `FORBIDDEN_WORD_AIRED`; emite
   `LINE_ADVANCED`; passa para a próxima linha. Depois da última linha:
   `BLOCK_FINISHED` e estado `FINISHED`.
3. `set_mic_held(false)` em `ON_AIR` → `DEAD_AIR` + `DEAD_AIR_STARTED`.
   Em `DEAD_AIR` o roteiro não avança e `dead_air_seconds` acumula.
   `set_mic_held(true)` volta para o estado anterior + `DEAD_AIR_ENDED`.
4. `audience_delta()` = `-floori(DEAD_AIR_TRUST_PER_SECOND * dead_air_seconds)`
   somado aos `immediate_deltas[AUDIENCE_TRUST]` dos improvisos
   escolhidos.
5. Ao entrar numa linha com `improv_point` não nulo: estado `IMPROV` +
   `IMPROV_REQUESTED`; o cronômetro do improviso conta por `tick`. O
   teleprompter não avança em `IMPROV`.
6. `choose_improv(i)` dentro do prazo → `IMPROV_RESOLVED`, registra a
   opção e volta a `ON_AIR` (ou `DEAD_AIR`, se o microfone estiver
   solto). Estourar `time_limit_seconds` → `IMPROV_TIMEOUT` e a opção de
   índice 0 é registrada.
7. Soltar o microfone durante `IMPROV` gera `DEAD_AIR` **e o cronômetro
   do improviso continua correndo**: o silêncio não é uma saída.
8. `replace_word(i)` só vale enquanto a linha que contém o slot ainda não
   foi ao ar; devolve false caso contrário. Sucesso emite
   `WORD_REPLACED` e o slot não gera infração.
9. `queue_call(t)` emite `CALL_TRANSCRIPT` na hora e agenda `CALL_AIRED`
   para `CALL_DELAY_SECONDS` de `tick` depois. `cut_call()` antes disso
   cancela e emite `CALL_CUT`; depois disso devolve false.
10. `LiveBroadcast` nunca toca em `Meters`: devolve deltas e infrações
    para quem o criou aplicar.

### 4.7 RadioResources / CrewMember / DayPhase

**RadioResources** (`radio_resources.gd`, RefCounted) — o contêiner
chega no **M6**, porque `RunState` o expõe; a lógica que o movimenta
(`DayPhase`) fica para o M11.

```gdscript
const FUEL := "fuel"       # inicial 40
const PARTS := "parts"     # inicial 2
const MONEY := "money"     # inicial 30
const REACH := "reach"     # inicial 50, alcance do sinal

func get_value(id: String) -> int
func apply(deltas: Dictionary) -> Dictionary   # id -> novo valor
func snapshot() -> Dictionary
static func all_ids() -> PackedStringArray
```

Nenhum recurso fica negativo. `REACH` é o único com teto (100): é uma
porcentagem de alcance, enquanto combustível, peças e dinheiro se
acumulam. Id desconhecido é ignorado, como em `Meters`.

**CrewMember** (`scripts/core/data/crew_member.gd`, Resource):
`id` · `display_name` · `skill: int` · `risk: int` ·
`status: enum Status { FREE, BUSY, ARRESTED, FLED, TRAITOR }`.

**DayPhase** (`day_phase.gd`, RefCounted):

```gdscript
enum Task { FETCH_PARTS, REFUEL, REPAIR, MOVE_HIDEOUT, CHANGE_FREQUENCY, REST }

func _init(resources: RadioResources, crew: Array[CrewMember], rng: RandomNumberGenerator) -> void
func assign(crew_id: String, task: Task) -> bool   # false se ocupado/preso
func assignments() -> Dictionary                   # crew_id -> Task
func resolve() -> Dictionary
```

`resolve()` devolve
`{resource_deltas, meter_deltas, arrested: Array[String], events: Array[Dictionary]}`.
Mais `reach` aumenta `REGIME_ATTENTION` na noite seguinte
(triangulação); `MOVE_HIDEOUT`/`CHANGE_FREQUENCY` reduzem. O risco de
prisão usa o `rng` injetado — com a mesma seed, o mesmo resultado.

### 4.8 RunState e NightCycle

**RunState** (`run_state.gd`, RefCounted) — o agregado de uma campanha.
Substitui `GameStateLogic` (ADR 0003).

```gdscript
const DEFAULT_TOTAL_NIGHTS := 21   # campanha até o referendo

func _init(total_nights: int = DEFAULT_TOTAL_NIGHTS, seed: int = 0) -> void
func meters() -> Meters
func notebook() -> Notebook
func queue() -> ConsequenceQueue
func resources() -> RadioResources
func rng() -> RandomNumberGenerator
func current_night() -> int
func flags() -> Dictionary
func set_flag(name: String) -> void
func advance_night() -> int
func total_nights() -> int
func is_finished() -> bool                 # current_night > total_nights
func record_aired(item: BroadcastItem, framing_kind: int) -> void
func aired_history() -> Array[Dictionary]  # cópia; {night, item_id, sender_id, item_type, framing_kind}
```

`record_aired` é como o `NightCycle` escreve no histórico; `aired_history`
devolve sempre uma cópia, para que ninguém escreva nele por fora.

**NightCycle** (`night_cycle.gd`, RefCounted) — as fases de uma noite.

```gdscript
enum Phase { TRIAGE, RUNDOWN, LIVE, MORNING, DAY, DONE }

func _init(definition: NightDefinition, run: RunState) -> void
func phase() -> Phase
func can_advance() -> bool
func advance() -> Phase
func inbox() -> Array[BroadcastItem]
func validator() -> Validator
func rundown() -> ProgramRundown
func live() -> LiveBroadcast            # válido a partir de LIVE
func resolve_live() -> void             # aplica deltas imediatos, agenda consequências
func morning_report() -> Dictionary     # {headlines, letters, meter_deltas, new_entries}
func day() -> DayPhase
```

- `TRIAGE → RUNDOWN` sempre pode avançar (não conferir é uma escolha).
- `RUNDOWN → LIVE` exige `rundown().is_ready()`.
- `LIVE → MORNING` exige `live().is_finished()`; `advance()` chama
  `resolve_live()`, que: aplica `audience_delta`, aplica os
  `immediate_deltas` dos enquadramentos, soma `order_effects`, converte
  cada infração em `REGIME_ATTENTION`, e agenda os `ConsequenceEffect` na
  `ConsequenceQueue` — **nada de consequência aparece nesta noite**.
  *Até o M9 não existe `LiveBroadcast`: a fase `LIVE` é uma passagem
  direta, `resolve_live()` faz tudo menos a parte que depende do ao vivo
  (`audience_delta` e infrações), e o portão `live().is_finished()` entra
  junto com o módulo, no M9.*
- **`DISCARD` não mexe em medidor na hora, mas tem consequência.** Os
  `immediate_deltas` de um enquadramento só são aplicados quando o item
  vai ao ar — a audiência não reage ao que não ouviu. Já os
  `consequence_ids` valem também para o descarte: não falar é uma
  resposta, e quem mandou o envelope azul entende como resposta. Por
  isso um `FramingOption` de tipo `DISCARD` **não deve ter**
  `immediate_deltas` (seriam ignorados em silêncio); o peso de descartar
  se escreve na consequência. Há teste de conteúdo cobrando isso.
- **A `condition` é resolvida na hora de agendar, não na manhã.** Em
  `resolve_live()` já se sabe tudo o que ela pergunta: se o item era
  falso, se foi ao ar (bloco com enquadramento diferente de `DISCARD`) e
  se o jogador o marcou como suspeito. Um efeito cuja condição não vale
  simplesmente não entra na fila. Isso mantém a `ConsequenceQueue` sem
  memória de item e a manhã sem regra de negócio.
- `MORNING` aplica tudo que `pop_due(night)` devolver: soma os
  `meter_deltas`, acrescenta as entradas de caderno dos
  `notebook_entry_ids`, marca os `flags_set` e junta manchetes e cartas
  no relatório.
- **Inconsistência:** `resolve_live()` compara o enquadramento aplicado a
  cada `sender_id` com o histórico em `RunState.aired_history()`. Dois
  enquadramentos são **opostos** quando um é `INFLAME` e o outro
  `SOFTEN`. Aplicar a um mesmo remetente um enquadramento oposto ao que
  já foi usado antes soma 1 a `INCONSISTENCY`, uma vez por noite por
  remetente.

### 4.9 EndingResolver v2 — `ending_resolver.gd`

A assinatura v0 `resolve(power: int) -> String` **permanece intocada até
o M12**, para não invalidar o loop jogável durante a construção. O M12
substitui a API e reescreve `tests/unit/test_ending_resolver.gd` (ADR
0003).

```gdscript
class_name EndingResult extends RefCounted   # scripts/core/ending_result.gd
var country_id: String
var personal_id: String
func composed_id() -> String                 # "reforma.martir"
```

```gdscript
static func resolve(meters: Meters, flags: Dictionary) -> EndingResult
static func resolve_country(snapshot: Dictionary, flags: Dictionary) -> String
static func resolve_personal(snapshot: Dictionary, flags: Dictionary) -> String
```

Limiares provisórios, calibrados para uma campanha de 21 noites e
revisados no M12, cada um com teste de fronteira:

País, na ordem:
1. `inconsistency >= 12` → `"colapso"`
2. `alignment > 65` → `"repressao"`
3. `alignment < 35` e `audience_trust >= 50` → `"reforma"`
4. senão → `"cinza"`

Pessoal, na ordem:
1. `integrity < 25` e `alignment >= 50` → `"cooptado"`
2. `integrity < 25` e `alignment < 35` → `"demagogo"`
3. `regime_attention >= 75` → `"preso"`
4. senão → `"lenda"`

---

## 5. Autoload GameState v1 (`scripts/game_state.gd`)

Continua sendo a única ponte entre lógica e cenas, e continua **não
decidindo nada**: delega para `RunState`/`NightCycle` e traduz em sinais.

### Sinais

```gdscript
signal phase_changed(phase: int)
signal night_started(night: int, quota: int)
signal inbox_ready(items: Array)
signal notebook_updated(new_entry_ids: Array)
signal link_evaluated(item_id: String, claim_id: String, entry_id: String, result: int)
signal suspicion_changed(item_id: String, suspicious: bool)
signal rundown_changed()
signal quota_changed(required: int, filled: int)
signal live_state_changed(state: int)
signal live_events(events: Array)
signal meter_changed(meter_id: String, new_value: int)
signal morning_ready(report: Dictionary)
signal day_ready(resources: Dictionary)
signal game_ended(country_id: String, personal_id: String)
```

**Invariante de vazamento:** `meter_changed` só é emitido para medidores
com `Meters.is_hidden(id) == false`. A UI não tem como exibir medidor
escondido porque nunca recebe o valor. (Teste: aplicar delta em
`REGIME_ATTENTION` não emite `meter_changed`.)

### Métodos

```gdscript
func start_run(seed: int = 0) -> void
func load_nights() -> void
func current_night() -> int
func current_phase() -> int
func advance_phase() -> void
func link_claim(item_id: String, claim_id: String, entry_id: String) -> void
func toggle_suspicion(item_id: String) -> void
func place_item(item_id: String, block_index: int) -> void
func move_block(from_index: int, to_index: int) -> void
func set_framing(block_index: int, kind: int) -> void
func set_mic_held(held: bool) -> void
func replace_word(slot_index: int) -> void
func choose_improv(option_index: int) -> void
func cut_call() -> void
func assign_crew(crew_id: String, task: int) -> void
func visible_meters() -> Dictionary
func reset_run() -> void
```

`_process(delta)` é o **único** ponto onde o tempo entra: durante a fase
`LIVE` chama `live().tick(delta)`, depois `drain_events()` e emite
`live_events`. Fora de `LIVE`, `_process` não faz nada.

---

## 6. Pipeline de pixel art (`tools/pixelart/`)

Decisão e justificativa: ADR 0004 (gerador) e ADR 0005 (resolução).

### Arquivos

| Caminho | Papel |
|---|---|
| `tools/pixelart/palette.gd` | `class_name PixelPalette`; `const COLORS: Dictionary` (nome → Color8) e `const FADED: Dictionary` (nome → nome esvaído) |
| `tools/pixelart/sprite_builder.gd` | `class_name PixelSpriteBuilder`; `static func build(def: Dictionary) -> Image` — pura, sem I/O |
| `tools/pixelart/sprite_defs/*.gd` | um arquivo por sprite; `static func definition() -> Dictionary` |
| `tools/pixelart/generate.gd` | script de `SceneTree` rodado headless: escreve os PNGs e o manifesto |
| `tools/pixelart/preview.gd` | imprime um sprite como texto no terminal, para conferir a arte sem abrir o editor |

### Formato de uma definição

```gdscript
static func definition() -> Dictionary:
    return {
        "name": "mic_base",
        "size": Vector2i(24, 18),
        "legend": {".": "", "a": "amber_hi", "b": "amber_mid"},
        "rows": PackedStringArray([
            "........aaaa........",
            # ...
        ]),
    }
```

`""` na legenda = pixel transparente. `rows.size()` deve ser igual a
`size.y` e cada linha deve ter `size.x` caracteres — `build` falha (e o
teste também) caso contrário.

### Geração

```
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s tools/pixelart/generate.gd
```

Escreve `assets/sprites/<name>.png` (versionados) e
`assets/sprites/manifest.json` com, por sprite: `name`, `path`, `width`,
`height`, `sha256` dos bytes RGBA e `palette` (nomes de cor usados).

**Determinismo:** rodar duas vezes produz PNGs byte a byte idênticos —
sem timestamps, sem RNG, iteração em ordem alfabética de `name`.

### Teste de manifesto — `tests/unit/test_asset_manifest.gd`

1. `manifest.json` carrega e não está vazio.
2. Todo `path` do manifesto existe e carrega como `Texture2D`.
3. `width`/`height` do PNG casam com o manifesto.
4. Toda cor não transparente do PNG está em `PixelPalette.COLORS`.
5. `PixelSpriteBuilder.build(def)` duas vezes produz `Image` com
   `get_data()` idêntico (determinismo, sem tocar disco).
6. Toda definição tem `rows.size() == size.y` e larguras consistentes.
7. Todo sprite exigido pela cena da mesa está no manifesto. A lista é a
   const `REQUIRED_SPRITES` dentro do próprio teste: é assim que a cena
   declara o que precisa, e um arquivo separado só para uma lista seria
   cerimônia (GUT também tentaria rodá-lo como teste).

Mais dois testes que nasceram junto e valem o preço:

8. `test_png_on_disk_matches_the_current_definition` — compara o `sha256`
   do manifesto com o que a definição produz agora. É o que pega "mexi na
   arte e esqueci de rodar o gerador".
9. `tests/unit/test_studio_desk_scene.gd` — a cena instancia, todo slot de
   textura está preenchido, nada escapa de 320×180, `TextureRect` nenhum
   estica pixel, e os 4 blocos não se sobrepõem.

Ler o PNG com `Image.load_from_file` em `res://` **não** serve: funciona
no editor, quebra no export, e o engine emite erro (que o GUT conta como
falha, corretamente). Os testes leem pela textura importada
(`load(path).get_image()`).

---

## 7. Mudanças em `project.godot` (M7, ADR 0005)

```ini
[display]
window/size/viewport_width=320
window/size/viewport_height=180
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
window/stretch/scale_mode="integer"

[rendering]
textures/canvas_textures/default_texture_filter=0   # Nearest
```

`canvas_items` + `scale_mode=integer` é o que permite o híbrido do ADR
0006: sprites em escala inteira sem borrar, fontes rasterizadas na
resolução final (texto legível). O M3 usa hoje `canvas_items`/`expand`;
a mudança para `keep` + `integer` é parte do aceite do M7, e o Theme
precisa de tamanhos de fonte reescalados para o espaço de 320×180.

---

## 8. Estratégia de testes

- Todo módulo de `scripts/core/` tem `tests/unit/test_<modulo>.gd`, e
  cada regra numerada deste documento vira pelo menos um teste.
- **Testes de fronteira obrigatórios:** clamps de `Meters`, limiares do
  `EndingResolver`, `pop_due` na noite exata do vencimento, índices de
  bloco inválidos, prazo do improviso exatamente no limite.
- **Testes de invariante** (barato e pega regressão de arquitetura):
  - `test_pure_logic_is_node_free.gd`: nenhum arquivo de `scripts/core/`
    contém `Time.`, `Timer`, `get_ticks`, `randi(`, `randf(`, `Input.`,
    `get_tree`, `_draw` ou `extends Node`.
  - `test_no_custom_draw.gd`: nenhum `.gd` de `scenes/` define `_draw`.
  - `test_hidden_meters_never_emitted.gd`: `meter_changed` não sai para
    medidor escondido.
- **Teste de integração da fatia vertical** (`test_night_one_run.gd`):
  roda a noite 1 de ponta a ponta sem cena nenhuma, com `tick` injetado e
  seed fixa, e verifica o relatório da manhã.
- Comando (Windows, caminho real do Godot neste PC):

```
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

- Depois de criar/editar script com `class_name` fora do editor:
  `C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless --import`.

---

## 9. Marcos

Concluídos (v0): **M0** projeto + GUT · **M1** dados e lógica v0 ·
**M2** autoload + cenas mínimas · **M3** Theme, fonte, transições.

O M4 da tabela antiga ("eventos reais substituindo os de teste") é
absorvido pelo M13, porque o formato de conteúdo muda com o
`NightDefinition`; escrever conteúdo no formato v0 agora seria trabalho
jogado fora.

A ordem abaixo ajusta a sugestão original em dois pontos, para manter
cada marco pequeno e revisável: a pixel art virou um marco só de pipeline
+ mesa estática (M7), e triagem/escalação ganhou o seu (M8). Total: M4 a
M14.

| Marco | Entrega | Critério de aceite |
|---|---|---|
| **M4** | Casa em ordem: branch principal, `.gitignore`, `.godot/` fora do índice, `docs/adr/`, `docs/ROADMAP.md`, `CLAUDE.md` atualizado | `git ls-files .godot` não devolve nada; `.gitignore` na raiz; `docs/adr/README.md` indexa os ADRs; suíte atual continua 19/19 verde |
| **M5** | Dados v1 (`ItemClaim`, `NotebookEntry`, `FramingOption`, `BroadcastItem`, `ConsequenceEffect`) + `Notebook` + `Validator`, TDD | `test_notebook.gd` e `test_validator.gd` cobrem as 3 saídas de `evaluate`, id repetido no caderno, e o caso "item fraudulento sem entrada no caderno → nenhuma contradição encontrada"; `data/nights/night_01.tres` com 4+ itens e ≥1 fraude detectável carrega em teste |
| **M6** | `Meters`, `ProgramRundown`, `ConsequenceQueue`, `RunState`, `NightCycle` (fases TRIAGE/RUNDOWN/MORNING) | Testes de: clamp e medidor escondido; bloco ocupado/índice inválido/troca por `move`; `quota_filled` com cota 1→3; `order_effects` casando a regra denúncia→propaganda; `pop_due` não entrega na mesma noite; `RUNDOWN→LIVE` bloqueado sem `is_ready()` |
| **M7** | Pipeline de pixel art + manifesto + cena da mesa estática + resolução/escala | `generate.gd` roda headless; duas execuções seguidas não mudam nenhum byte dos PNGs (hash igual); `test_asset_manifest.gd` verde nos 7 pontos da §6; mesa monta com `TextureRect`/`NinePatchRect`, `test_no_custom_draw.gd` verde; `project.godot` com integer scaling |
| **M8** | Triagem e escalação: celular/cartas/caderno em close, marcar e cruzar, arrastar para os 4 blocos | Jogável manualmente da triagem até `is_ready()`; drag-and-drop só com `_get_drag_data`/`_can_drop_data`/`_drop_data`; nenhuma variável de estado de jogo nos scripts de cena; UI da cota reage a `quota_changed` |
| **M9** | Ao vivo: `LiveBroadcast` + teleprompter, microfone/ar morto, palavras proibidas, improviso, ligação com delay | `test_live_broadcast.gd` cobre as 10 regras da §4.6 com `tick` determinístico; `test_pure_logic_is_node_free.gd` verde; jogável manualmente um bloco inteiro |
| **M10** | Manhã: manchetes, cartas de consequência, caderno crescendo → **fatia vertical: noite 1 de ponta a ponta** | `test_night_one_run.gd` roda TRIAGE→MORNING headless com seed fixa e verifica o relatório; jogável manualmente do primeiro item à manhã; nenhuma consequência aparece na mesma noite (teste) |
| **M11** | Fase de dia: transmissor, sinal, equipe, dinheiro | `test_day_phase.gd`: mesma seed → mesmo `resolve()`; equipe presa não aceita tarefa; `reach` alto aumenta `REGIME_ATTENTION` na noite seguinte |
| **M12** | Finais país × pessoal (`EndingResolver` v2, substitui a v0) | `test_ending_resolver.gd` reescrito com teste de fronteira para cada limiar da §4.9; os 7 finais da v0 alcançáveis como pares país×pessoal; cena de final mostra os dois textos |
| **M13** | Conteúdo das noites até o referendo + corte da internet (era PHONE → LETTERS) | Toda `night_NN.tres` passa num teste de sanidade (cota ≥ 1, inbox > 4, todo `consequence_id` e `notebook_entry_id` referenciado existe, `IRONY` só em `PROPAGANDA`); a noite do corte muda o `era` e a UI |
| **M14** | Som e polimento: trilha como sinal, ruído de dial, esvair da paleta | Trilha selecionável entre blocos com código do caderno; degradação de cor conforme ADR 0008; suíte inteira verde |

---

## 10. Rastreabilidade design → spec

| Seção do design | Onde está especificado |
|---|---|
| Loop da noite (§2) | `NightCycle` §4.8, fases e transições |
| Itens e remetentes (§3) | `BroadcastItem` §3 |
| Cota de propaganda (§3) | `ProgramRundown` §4.4 |
| Enquadramentos (§4) | `FramingOption` §3 |
| Caderno e validação (§5) | `Notebook` §4.2, `Validator` §4.3 |
| Ao vivo (§6) | `LiveBroadcast` §4.6 |
| Medidores (§7) | `Meters` §4.1 + ADR 0002 |
| Fase de dia (§8) | `DayPhase` §4.7 |
| Celular → cartas (§9) | `NightDefinition.era` §3, M13 |
| Finais (§11) | `EndingResolver` v2 §4.9 |
| Tela (§12) | M7 (mesa) e M8 (closes) |
| Estética (§13) | §6, §7, ADRs 0004/0005/0006/0008 |
