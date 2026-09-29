# 0006 — Texto híbrido nos documentos em close

- **Status:** aceito
- **Data:** 2026-09-29

## Contexto

O jogo é de ler: cartas, mensagens de celular, o caderno do apresentador e
o roteiro do teleprompter. São blocos de texto que o jogador precisa
conferir palavra por palavra, cruzando um trecho com outro. Ao mesmo tempo
a estética é pixel art em 320×180 (ADR 0005).

Fonte em pixel art numa base de 320×180 dá cerca de 4×6 px por caractere:
caberiam umas 50 colunas e 20 linhas por tela, com legibilidade ruim em
qualquer escala. Não serve para uma carta inteira nem para o caderno.

## Decisão

Documentos em close são **híbridos**:

- **Moldura, papel, envelope, carimbo, lacre, tela do celular, capa e
  divisórias do caderno:** pixel art gerada pelo pipeline do ADR 0004,
  em `TextureRect`/`NinePatchRect` com filtro nearest.
- **Texto do conteúdo:** Courier Prime (já no projeto, SIL OFL), em
  `RichTextLabel`/`Label`, rasterizado na resolução da janela pelo
  `canvas_items` scaling do ADR 0005 — nítido, não pixelado.
- A **letra manuscrita** de uma carta é sugerida por pixel art (um sprite
  de rabisco na assinatura, na margem, no endereço), nunca por uma fonte
  cursiva: a fonte monoespaçada é a "voz do jogo", e a letra à mão é
  detalhe visual conferível no caderno.
- O texto do teleprompter segue a mesma regra: moldura de pixel art,
  texto nítido, porque é onde o jogador tem que enxergar uma palavra
  proibida escondida no meio da frase.

Regra de ouro: **pixel art não carrega informação textual**. Se o jogador
precisa ler para decidir, é fonte; se é textura, é pixel.

## Alternativas consideradas

- **Tudo em fonte de pixel (bitmap font).** Rejeitado: coerente
  visualmente, ilegível na prática para o volume de leitura do jogo, e o
  ato central (achar a contradição no texto) depende de legibilidade.
- **Tudo em fonte nítida, sem molduras de pixel.** Rejeitado: o jogo
  perderia a identidade visual justamente nas telas onde o jogador passa
  mais tempo.
- **Texto renderizado em `Viewport` de alta resolução e aplicado como
  textura.** Rejeitado: complexidade sem ganho — `canvas_items` já entrega
  texto nítido.
- **Fonte de pixel para o caderno (poucas palavras) e nítida para
  cartas.** Rejeitado: duas gramáticas tipográficas na mesma mecânica de
  cruzar trecho com trecho; o jogador compararia coisas com aparência
  diferente.

## Consequências

- A tela tem duas "resoluções" visíveis ao mesmo tempo. É uma escolha
  estética assumida, comum no gênero (documento legível sobre cenário
  pixelado), e ajuda a separar "objeto do mundo" de "coisa que você lê".
- Sprites de moldura precisam de `NinePatchRect` com margens bem
  definidas, para esticar sem deformar o pixel. O manifesto de assets
  registra as margens de cada moldura.
- O teste de manifesto não valida texto; o que garante legibilidade é
  revisão manual no M8.
