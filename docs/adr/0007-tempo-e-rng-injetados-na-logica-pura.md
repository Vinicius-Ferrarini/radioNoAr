# 0007 — Tempo e RNG injetados; eventos drenados em vez de sinais

- **Status:** aceito
- **Data:** 2026-09-29

## Contexto

A mecânica central da v1 é o ao vivo: o teleprompter sobe por segundo, o ar
morto custa audiência por segundo, o improviso tem prazo, a ligação tem
7 s de delay. Tudo isso é tempo real, e tempo real é o que normalmente
torna um sistema de jogo impossível de testar sem abrir a janela.

O `CLAUDE.md` exige lógica pura em `RefCounted`, sem `Node`. Um `Timer` é
`Node`; `Time.get_ticks_msec()` é global e não determinístico; `signal`
exige `Object` (funciona em `RefCounted`, mas obriga o teste a instalar
watchers e a lógica a conhecer quem escuta).

## Decisão

1. **Tempo injetado.** Todo módulo com duração expõe
   `func tick(delta: float) -> void` e não consulta relógio nenhum.
   Proibido em `scripts/core/`: `Time.`, `Timer`, `get_ticks_*`,
   `OS.get_*`, `await`, `get_tree()`, `process`.
2. **Um único ponto de entrada de tempo:** `GameState._process(delta)`,
   que durante a fase `LIVE` chama `live().tick(delta)`. Nenhum outro
   script chama `tick`.
3. **RNG injetado.** Quem sorteia recebe um `RandomNumberGenerator` criado
   por `RunState` com seed explícita (`start_run(seed)`). Proibido
   `randi()`/`randf()` global. Mesma seed + mesmas entradas = mesmo
   resultado, o que dá testes de fase de dia determinísticos e
   possibilita reproduzir um bug a partir da seed.
4. **Eventos drenados, não sinalizados.** A lógica pura acumula
   ocorrências numa fila e as entrega em
   `drain_events() -> Array[Dictionary]` (cada item com uma chave `kind`
   de um enum do próprio módulo). O autoload drena a cada `_process` e
   traduz em sinais Godot para as cenas. A lógica pura não tem `signal`.
5. **Determinismo de teste:** um teste avança o estado com passos fixos
   (`for i in 60: live.tick(1.0 / 60.0)`), e a asserção é sobre estado e
   fila de eventos, nunca sobre "esperar".

## Alternativas consideradas

- **`Timer`/`await` dentro da lógica.** Rejeitado: quebra a camada pura e
  torna o teste dependente do `SceneTree`, com testes lentos e
  intermitentes.
- **`signal` direto no `RefCounted`.** Funciona tecnicamente, mas faz a
  lógica saber que existe alguém escutando e obriga todo teste a usar
  `watch_signals`. Com `drain_events`, o teste só lê um array. Rejeitado
  também porque sinal disparado no meio de um `tick` deixa o estado
  observável no meio de uma transição.
- **Tempo em milissegundos inteiros** em vez de `delta` float. Rejeitado:
  atrito com o `_process(delta: float)` do Godot, e o teste ganha
  determinismo pelo tamanho fixo do passo, não pelo tipo.

## Consequências

- Os testes do ao vivo (M9) rodam headless em milissegundos e não piscam.
- A fila de eventos é estado: quem drena consome. Se dois consumidores
  precisarem dos mesmos eventos, o autoload distribui — a lógica pura
  continua com um só dono.
- `Dictionary` em `drain_events` não é tipado. A contrapartida é que cada
  `kind` tem o seu formato documentado no SPEC §4.6 e um teste que checa
  as chaves; um `Resource` de evento por tipo seria mais seguro e muito
  mais cerimonioso para dados que vivem um frame.
- Um teste de invariante (`test_pure_logic_is_node_free.gd`) varre
  `scripts/core/` procurando os identificadores proibidos, para que a
  regra não dependa de disciplina.
