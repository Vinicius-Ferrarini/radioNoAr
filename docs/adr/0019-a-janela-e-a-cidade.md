# 0019 — A janela é a cidade

- **Status:** aceito e implementado em 2026-10-01.

## Contexto

A parede atual divide atenção entre uma janela pequena, teleprompter,
toca-discos, lembranças e painéis. A cidade deveria comunicar visualmente a
mudança política e social da campanha: tráfego, proibições, bicicletas,
pedestres e revolta. A composição atual não reserva espaço para isso.

## Decisão

A área visível do estúdio passa a ter somente uma janela panorâmica, o
letreiro `NO AR` e o microfone. Os objetos de interação continuam na mesa.
O teleprompter permanece como nó técnico oculto por compatibilidade com a
transmissão atual.

A janela será um contêiner recortado com base visual da cidade e camadas
separadas para rua, pessoas e eventos. Nesta entrega as camadas dinâmicas
ficam vazias; nenhuma regra ou estado novo é adicionado.

## Consequências

- A parede se torna mais simples e a cidade ganha prioridade visual.
- A futura evolução da janela pode ocorrer somente na apresentação.
- Toca-discos e lembranças deixam de aparecer no estúdio, embora seus estados
  continuem existindo para outras superfícies futuras.
- A leitura ao vivo ainda existe internamente, mas não é desenhada como
  teleprompter na sala.

Plano executável: `../PLANO_ESTUDIO_JANELA_PANORAMICA.md`.
