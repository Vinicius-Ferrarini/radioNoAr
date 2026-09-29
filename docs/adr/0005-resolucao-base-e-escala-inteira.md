# 0005 — Resolução base, escala inteira e filtro de textura

- **Status:** aceito
- **Data:** 2026-09-29

## Contexto

Hoje `project.godot` tem `window/stretch/mode="canvas_items"` e
`aspect="expand"`, sem resolução base definida e com filtro de textura
linear (padrão). Isso serve para UI de texto, mas borra pixel art e
permite escalas fracionárias, que produzem pixels de tamanhos diferentes
na mesma tela.

Existe uma tensão real: pixel art quer escala inteira e filtro nearest;
os documentos em close (cartas, celular, caderno) querem texto legível,
com bastante texto na tela (ADR 0006).

## Decisão

Resolução base **320×180**, janela padrão 1280×720 (4×), escala inteira:

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

O ponto central é **`canvas_items` + `scale_mode="integer"`**, e não
`stretch/mode="viewport"`:

- `viewport` renderiza tudo num framebuffer de 320×180 e depois amplia —
  o texto sairia pixelado junto com os sprites, e texto pixelado em
  320×180 não comporta a quantidade de leitura que o jogo exige.
- `canvas_items` escala a transformação do canvas: os sprites, com filtro
  nearest e fator inteiro, ficam com pixels perfeitos; as fontes são
  rasterizadas na resolução final da janela, ficando nítidas. É
  exatamente o híbrido do ADR 0006, sem shader nem viewport extra.

`aspect="keep"` mantém a proporção 16:9 com barras, em vez de revelar mais
mundo em telas largas (o design é de uma tela fixa, uma mesa só).

## Alternativas consideradas

- **480×270 como base.** Mais espaço para texto e para os 4 blocos, menos
  "pixel grande". Rejeitado por pouco: 320×180 dá 4× exato em 720p e 6×
  em 1080p, e força a composição a ser econômica — o que combina com uma
  tela única. Se no M8 os closes não couberem, este ADR é substituído por
  um com 480×270; a mudança é de duas linhas em `project.godot` e dos
  tamanhos do Theme.
- **`stretch/mode="viewport"`.** Rejeitado: texto ilegível (acima).
- **Dois viewports (um pixelado, um de UI nítida).** Rejeitado: resolve o
  mesmo problema que `canvas_items` resolve sozinho, ao custo de uma
  árvore de cena mais complicada e de ter que sincronizar input entre
  viewports.
- **Escala fracionária (`scale_mode="fractional"`).** Rejeitado: pixels de
  tamanhos diferentes na mesma imagem.

## Consequências

- O Theme do M3 precisa ser reescalado: fonte 20/28 não existe em um
  espaço de 320×180. Os tamanhos passam para a ordem de 6–10 px, ainda
  nítidos porque a rasterização acontece na resolução da janela. Isso faz
  parte do aceite do M7.
- Todo posicionamento de UI passa a ser pensado em unidades de 320×180.
  Layouts feitos antes do M7 (`radio_show.tscn`, `ending.tscn`) ficam
  desalinhados — e as duas cenas são refeitas no M7/M8 de qualquer forma.
- Em janela redimensionada aparecem barras. É intencional.
