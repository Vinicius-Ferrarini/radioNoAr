# 0008 — Como a cor se esvai conforme o cerco aperta

- **Status:** aceito
- **Data:** 2026-09-29

## Contexto

O design pede que a cor "se esvaia" ao longo da campanha: o estúdio começa
em âmbar quente (lâmpada, válvulas) contra o azul frio da rua, e vai
perdendo saturação conforme o cerco aperta. Duas implementações possíveis:
paletas alternativas geradas em PNG, ou um efeito aplicado em tempo de
execução.

Restrição do `CLAUDE.md`: nada de `_draw()`, e a UI precisa continuar
editável no editor.

## Decisão

Um **`CanvasModulate` + `ColorRect` de mistura**, dirigido por um estágio
discreto de cerco — sem shader e sem paletas duplicadas.

- `RunState` expõe `siege_stage() -> int` (0 a 3), derivado da noite e de
  `regime_attention`. Estágio é **discreto** de propósito: quatro looks
  reconhecíveis, não um gradiente contínuo que ninguém percebe.
- Cada estágio tem um `Color` de `CanvasModulate` e um alpha de um
  `ColorRect` cinza-azulado em `BLEND_MODE_MIX` cobrindo a cena. Os quatro
  pares ficam num `Resource` em `data/look/siege_stages.tres`, editável no
  editor.
- A transição entre estágios é um `Tween` de alguns segundos na virada da
  noite, em `scenes/`, nunca na lógica.
- `PixelPalette.FADED` (ADR 0004) continua existindo, mas com outro
  propósito: gerar *variantes de sprite* para os poucos casos em que
  modulação global não basta (a lâmpada apagada, a válvula queimada).

## Alternativas consideradas

- **Gerar quatro paletas completas de PNG** (uma por estágio) e trocar as
  texturas. Rejeitado: multiplica por quatro os assets e o tempo de
  geração, e obriga cada `TextureRect` a saber em que estágio está — o
  contrário de editável.
- **Shader de LUT** (mapa de cores por paleta). É a solução tecnicamente
  mais bonita e a mais fiel a "trocar de paleta". Rejeitado por ora: mais
  código de render para manter, um `.gdshader` que o editor não mostra
  como está, e ganho pequeno sobre modulação + mistura numa paleta que já
  é limitada. Se em algum marco a modulação global amassar as cores
  (âmbar e azul convergindo para o mesmo cinza), este ADR é substituído
  por um de LUT.
- **Modulação contínua por noite** (alpha proporcional a `night /
  total_nights`). Rejeitado: mudança imperceptível entre noites, e nenhum
  momento em que o jogador nota que o mundo ficou mais frio.

## Consequências

- Precisa haver teste do mapeamento, não do visual:
  `test_siege_stage.gd` verifica as fronteiras de `siege_stage()`. O look
  em si é revisão manual (M14).
- `CanvasModulate` afeta tudo na cena, inclusive o texto dos closes. Isso
  é desejável (a carta também esfria), mas o alpha máximo do estágio 3
  precisa ser limitado para não prejudicar a leitura — o critério é o
  contraste do texto do caderno, checado à mão no M14.
- O estágio de cerco é informação *sobre* o regime, e o regime não tem
  medidor. Aqui não há contradição: o jogador vê o mundo esfriar, não um
  número. É exatamente o tipo de sinal vago que o design pede.
