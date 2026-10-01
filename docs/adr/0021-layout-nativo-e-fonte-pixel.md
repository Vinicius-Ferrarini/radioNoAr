# 0021 — Layout nativo e fonte pixel

- **Status:** aceito — solicitado pelo dono em 2026-10-01.

## Contexto

O ADR 0020 aumentou o canvas e as fontes dos sprites, mas preservou a mesa
antiga por uma escala 2× no nó pai. Texturas nearest continuam nítidas; já a
Courier Prime TTF de 7 px carrega antialiasing e subpixel para dentro dessa
ampliação. O halo dos glifos faz toda a tela parecer borrada.

## Decisão

A interface passa a ser composta diretamente em 640×360. Todas as coordenadas
visuais, fontes, margens e animações são migradas para 2× e a escala do nó pai
é removida. Courier Prime continua sendo a família do jogo, mas é importada
sem antialiasing e sem posicionamento subpixel, com tamanho-base 14 px.

## Consequências

- Sprites 2× passam a mapear 1:1 para o canvas nativo.
- Texto ganha contorno seco e coerente com pixel art.
- A densidade visual não depende de transformação de ancestral.
- Novas telas devem ser desenhadas diretamente em 640×360.

Plano executável: `../PLANO_LAYOUT_NATIVO_E_TEXTO_NITIDO.md`.
