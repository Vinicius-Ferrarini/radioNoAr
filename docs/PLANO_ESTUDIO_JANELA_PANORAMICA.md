# Plano — estúdio com janela panorâmica

## Objetivo

Transformar a parede do estúdio em uma moldura para a cidade. A área superior
deve mostrar somente uma janela grande, o letreiro `NO AR` e o microfone. Os
objetos jogáveis continuam sobre a mesa.

## Direção visual

- Janela panorâmica ocupando quase toda a largura e altura útil da parede.
- Cidade noturna com profundidade: céu, prédios, janelas, postes, calçada e
  rua vazia nesta entrega.
- Letreiro `NO AR` preso ao lado direito da janela.
- Microfone em primeiro plano, também à direita.
- Teleprompter, toca-discos, painel decorativo, luminária, dial e lembranças
  não aparecem na composição do estúdio.

## Preparação para a cidade viva

O nó da janela recorta quatro camadas de apresentação:

1. base da cidade;
2. rua/tráfego;
3. pessoas;
4. eventos e atmosfera.

Nesta entrega somente a base é desenhada. As camadas adicionais ficam vazias
e não possuem lógica de jogo. Futuramente poderão receber carros, motos,
bicicletas, pedestres, manifestações, bloqueios e mudanças de iluminação sem
alterar a moldura do estúdio.

## Implementação

1. Registrar a decisão no SPEC e no ADR 0019.
2. Criar conceito visual e traduzi-lo para o pipeline determinístico.
3. Ampliar `window_night` e redesenhar `studio_wall`.
4. Reorganizar a cena mantendo visíveis somente janela, `NO AR` e microfone.
5. Manter o teleprompter como nó técnico oculto enquanto a apresentação ao
   vivo ainda depende de seu texto interno.
6. Atualizar testes de composição, regenerar assets e executar QA renderizado.

## Critérios de aceite

- Janela com pelo menos 250×96 pixels na resolução base.
- Camadas `StreetLayer`, `PeopleLayer` e `EventLayer` existem e começam vazias.
- Teleprompter e demais equipamentos antigos permanecem invisíveis antes e
  durante o programa.
- Microfone, janela e `NO AR` ficam dentro de 320×180 e não se sobrepõem aos
  objetos jogáveis da mesa.
- Pipeline determinístico, suíte completa e QA renderizado passam.

## Resultado — 2026-10-01

- Janela implementada em 264×102 px, com céu, skyline, bairro, postes,
  calçada e rua vazia.
- `StreetLayer`, `PeopleLayer` e `EventLayer` criadas dentro do recorte da
  janela e deixadas vazias para a evolução da cidade.
- Teleprompter, toca-discos, painel decorativo e lembranças retirados da
  composição visível; janela, `NO AR` e microfone permanecem.
- Conceito aprovado guardado em
  `references/estudio-janela-panoramica-conceito.png`.
- Pipeline regenerado, treze capturas renderizadas concluídas e suíte
  **352/352**, com **232.987 asserts**.
