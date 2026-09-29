# No Ar — Especificação Técnica (SDD)

Este documento é a fonte de verdade técnica. Código deve implementar o
que está aqui; se um comportamento não está descrito, pare e proponha
uma adição a este arquivo antes de implementar.

## Modelo de dados (Resources)

### Choice (extends Resource) — scripts/core/choice.gd
- id: String
- label: String            # texto do botão
- response_text: String    # o que o jogador "diz no ar"
- power_delta: int          # -100..100
- integrity_delta: int      # -100..100 (não usado na resolução ainda)
- stance: enum { TRUTH, CROWD_PLEASING, ATTACK }

### RadioEvent (extends Resource) — scripts/core/radio_event.gd
- id: String
- night: int
- headline: String
- body: String
- choices: Array[Choice]   # sempre 3

## Lógica pura (sem nós de cena, testável isoladamente)

### GameStateLogic (extends RefCounted) — scripts/core/game_state_logic.gd
Estado interno:
- power: int = 50
- integrity: int = 50
- inconsistency: int = 0
- current_night: int = 1
- history: Array[Choice] = []

Métodos:
- apply_choice(choice: Choice) -> void
  - soma power_delta a power, clamp 0-100
  - soma integrity_delta a integrity, clamp 0-100 (guardado, não usado ainda)
  - adiciona choice a history
  - incrementa current_night
- is_finished(total_nights: int) -> bool
- resolve_ending() -> String
  - delega para EndingResolver.resolve(power) nesta v0

### EndingResolver (extends RefCounted, métodos estáticos) —
scripts/core/ending_resolver.gd
- static func resolve(power: int) -> String
  - power > 65  -> "repressao"
  - power < 35  -> "reforma"
  - caso contrário -> "cinza"
  - (extensão futura: receber integrity/inconsistency e cobrir os 7 finais;
    deixar reservado, não implementar agora)

## Autoload (ponte entre lógica pura e cenas)

### GameState (autoload, extends Node) — scripts/game_state.gd
Possui uma instância interna de GameStateLogic e apenas delega/expõe:
- signal power_changed(new_value: int)
- signal night_advanced(new_night: int)
- signal game_ended(ending_id: String)
- func load_events() -> void   # carrega os RadioEvent de res://data/events/
- func get_current_event() -> RadioEvent
- func apply_choice(choice: Choice) -> void  # chama a lógica, emite sinais
- func reset_run() -> void

Regra: GameState NUNCA contém lógica de decisão própria, só delega para
GameStateLogic e traduz o resultado em sinais.

## Dados de teste (v0)
3 RadioEvent em res://data/events/ (formato .tres), noites 1-3, cada um
com 3 Choice cobrindo os 3 stances, com power_delta variado o bastante
para permitir alcançar os 3 finais em testes.

## Testes (GUT, em res://tests/unit/)
- test_choice_application.gd: aplicar choice muda power corretamente e
  faz clamp em 0 e 100.
- test_ending_resolver.gd: casos de fronteira — power=66 -> "repressao",
  power=65 -> "cinza", power=34 -> "reforma", power=35 -> "cinza",
  power=50 -> "cinza".
- test_game_state_flow.gd: aplicar 3 choices avança 3 noites e emite
  game_ended com o ending_id esperado.

## Apresentação (M3) — Theme, fonte, transições, barra animada

A linha do M3 na tabela de Marcos é resumida demais para implementar sem
ambiguidade (qual fonte? qual paleta? que tipo de transição?). Esta seção
fixa as decisões antes da implementação:

- **Fonte:** Courier Prime (SIL OFL, já presente em addons/gut/fonts/),
  copiada para res://assets/fonts/ (com o OFL.txt de atribuição). Regular
  para corpo de texto, Bold para headline do evento e texto do final.
  Escolhida pelo tom de "transmissão de rádio sob censura" do design —
  é uma fonte de telex/máquina de escrever.
- **Theme (res://theme/theme.tres):** aplicado ao nó raiz de
  radio_show.tscn e ending.tscn. Define fonte padrão (Courier Prime
  Regular, tamanho 20) e fonte de destaque (Bold, tamanho 28) para
  headline/labels de título. Paleta: fundo quase preto (#12100e), texto
  quase branco (#e8e4da), destaque (preenchimento de barra e botões) em
  vermelho apagado (#b23a2f). Estilo de Button com StyleBoxFlat de
  cantos retos (sem arredondamento), reforçando estética de painel de
  controle.
- **Barra de Poder animada:** ao receber power_changed, radio_show.gd
  anima o valor da ProgressBar via Tween (0.35s, TRANS_SINE, EASE_OUT)
  em vez de saltar instantaneamente. Puramente visual — não afeta
  GameStateLogic/EndingResolver.
- **Transições de cena:** um ColorRect "FadeOverlay" preto cobrindo a
  tela em radio_show.tscn e ending.tscn. Ao trocar de cena (fim de jogo
  ou "Jogar novamente"), a cena atual anima o overlay de alpha 0 -> 1 em
  0.3s antes de chamar change_scene_to_file(); a cena carregada começa
  com o overlay em alpha 1 e anima para 0 em 0.3s no _ready().
- Nada disso introduz lógica de decisão nova; a lógica de
  cor/animação/transição vive só nos scripts de cena
  (scenes/radio_show.gd, scenes/ending.gd), que continuam apenas
  escutando sinais do GameState e chamando seus métodos. Como não há
  lógica pura nova em scripts/core/, o M3 não adiciona testes GUT novos;
  o critério de regressão é os testes existentes (M0-M2) continuarem
  100% passando headless.

## Marcos

| Marco | Entrega | Critério de aceite |
|---|---|---|
| M0 | Projeto Godot + GUT instalado e rodando | 1 teste trivial passa via CLI headless |
| M1 | Choice, RadioEvent, GameStateLogic, EndingResolver + testes | Todos os testes de M1 passam headless, SEM nenhuma cena/UI ainda |
| M2 | GameState autoload + cenas RadioShow/Ending mínimas | Jogável manualmente do início ao fim, 3 finais alcançáveis |
| M3 | Theme.tres, fonte, transições, barra animada | Visual coerente, sem código de lógica nas cenas |
| M4 | Eventos reais de docs/GAME_DESIGN.md substituindo os de teste | Primeiras noites reais jogáveis |
