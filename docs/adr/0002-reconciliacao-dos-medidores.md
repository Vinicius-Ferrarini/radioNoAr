# 0002 — Reconciliação dos medidores (v0 × v1)

- **Status:** aceito — Opção A (decisão do designer em 2026-09-29)
- **Data:** 2026-09-29

## Contexto

Existem dois modelos de medidores no material:

- **v0 (implementado):** Poder (visível, 0–100, povo ↔ governo),
  Integridade (escondida, 0–100), Inconsistência (contador, força o
  Colapso acima de um limite).
- **v1 (design novo):** Confiança da audiência, Atenção do regime,
  Temperatura das ruas, Recursos da rádio.

Os dois não são redundantes: a v1 descreve *pressões* de curto prazo que
reagem noite a noite, enquanto Integridade e Inconsistência da v0 são
*memória de caráter* de longo prazo, e é delas que sai o destino pessoal.
O que falta na v1 é um eixo explícito povo ↔ governo, que é exatamente o
"Poder" da v0 — o nome é que engana, porque não mede poder, mede
alinhamento.

Restrição forte do design: **o regime não tem medidor visível**. Logo
Atenção do regime precisa ser escondida, e a UI não pode nem receber o
valor.

## Decisão

**Opção A (escolhida):** seis eixos guardados, "Poder" renomeado para
`ALIGNMENT`.

| Id | Faixa | Visibilidade | Origem |
|---|---|---|---|
| `audience_trust` | 0–100 | visível (ponteiro de ouvintes) | v1 |
| `street_heat` | 0–100 | visível, leitura qualitativa | v1 |
| `regime_attention` | 0–100 | **escondida** | v1 |
| `alignment` | 0–100 (0 povo, 100 governo) | visível | v0 (`power`) |
| `integrity` | 0–100 | **escondida** | v0 |
| `inconsistency` | contador ≥ 0 | **escondida** | v0 |

Recursos da rádio **não** são medidores: viram `RadioResources`
(combustível, peças, dinheiro, alcance), porque têm unidade própria, não
são 0–100 e pertencem à fase de dia.

O `EndingResolver` v2 usa: país ← `alignment`, `audience_trust`,
`inconsistency`; pessoal ← `integrity`, `alignment`, `regime_attention`
(ver SPEC §4.9).

Invariante de implementação: `Meters.is_hidden(id)` é a única fonte de
verdade sobre visibilidade, e `GameState` só emite `meter_changed` para
medidores visíveis — a UI fica incapaz de vazar estado escondido.

## Alternativas consideradas

- **Opção B: cinco eixos, `alignment` derivado** de
  `regime_attention - audience_trust`. Rejeitada como recomendação:
  tira do designer a capacidade de dizer "este enquadramento agrada ao
  governo sem mexer na audiência" (ex.: ler a nota do Ministério sem
  questionar), e acopla duas grandezas que o design trata como
  independentes.
- **Opção C: descartar Integridade e Inconsistência** e derivar o destino
  pessoal do histórico de enquadramentos. Rejeitada: espalha a regra pelo
  histórico, fica caro de testar, e joga fora o gatilho de Colapso que já
  está desenhado.
- **Opção D: sete eixos, mantendo `power` e `alignment` separados.**
  Rejeitada: ninguém conseguiu descrever a diferença entre os dois.

## Consequências

- `power` deixa de existir como nome. O rename atinge
  `GameStateLogic`, `GameState.power_changed`, `Choice.power_delta`,
  `radio_show.gd` e os `.tres` de evento — por isso acontece junto da
  migração do ADR 0003, no M6, e não antes.
- Seis eixos é muito para mostrar na tela, e é de propósito: três são
  escondidos e um é qualitativo. A HUD mostra dois números
  (`audience_trust`, `alignment`) e um estado de rua.
- Se em algum marco o `alignment` provar ser redundante com
  `audience_trust` na prática (os dois sempre andando juntos), o caminho
  é a Opção B em um ADR novo — não a edição deste.
