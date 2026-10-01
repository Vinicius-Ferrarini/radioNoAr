# 0020 — Canvas e fontes de sprite em densidade 2×

- **Status:** aceito e implementado em 2026-10-01.

## Contexto

O canvas 320×180 limita a quantidade de detalhe que cabe nos personagens.
`Papers, Please`, a referência direta, usa 570×320. Trocar literalmente para
essa medida faria a composição existente crescer cerca de 1,78×, uma escala
fracionária que deforma pixels e bordas.

## Decisão

O canvas nativo passa a 640×360 e a janela padrão permanece 1280×720. Uma
cena-raiz escala a composição lógica 320×180 exatamente 2×. O pipeline passa
a exportar os PNGs com duas vezes a largura e a altura; retratos podem usar o
novo subpixel da fonte para ganhar detalhe sem mudar seu tamanho na interface.

Esta decisão substitui a resolução-base do ADR 0005. A regra de filtro nearest
e escala inteira continua valendo. O formato permanece RGBA8 e a paleta não
muda.

## Consequências

- Há quatro vezes mais pixels nativos para desenhar cada área da interface.
- A posição dos controles e a lógica de hit testing permanecem no grid
  conhecido de 320×180.
- Assets antigos podem migrar primeiro por nearest-neighbor e depois receber
  detalhes de um pixel de fonte sem alterar cenas.
- Capturas de QA passam a medir 640×360.

Plano executável: `../PLANO_RESOLUCAO_E_SPRITES_2X.md`.
