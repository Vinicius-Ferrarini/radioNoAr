# Plano — layout nativo e texto nítido

## Problema

O canvas é 640×360, mas a interface ainda é composta em 320×180 e ampliada
por `StudioDesk.scale = 2`. A Courier Prime continua rasterizada em 7 px com
antialiasing e posicionamento subpixel. O resultado amplia bordas cinzentas
dos glifos e dá aparência borrada à tela.

## Objetivo

Compor toda a apresentação diretamente em 640×360, sem escala em ancestral,
e rasterizar a tipografia como pixel art nítida.

## SDD — comportamento especificado

- `StudioDesk` mede 640×360 e tem escala `Vector2.ONE`.
- Posições, tamanhos, margens, bordas, fontes e animações usam coordenadas
  nativas 2×.
- Cada `TextureRect` de tamanho fixo mede exatamente o tamanho de sua fonte
  PNG 2×; não há redução seguida de ampliação.
- Courier Prime usa antialiasing desligado, posicionamento subpixel desligado,
  hinting normal e fonte-base 14 px.
- O canvas 640×360 continua abrindo em 1280×720 por escala inteira 2×.

## TDD

1. Alterar primeiro os testes de configuração e geometria para exigir escala
   unitária, mesa 640×360, janela panorâmica 528×204 e texturas 1:1.
2. Criar teste para as configurações de importação das duas fontes e tamanho
   base 14 px.
3. Executar os testes e registrar a falha esperada antes da implementação.
4. Migrar cenas, tema e coordenadas dinâmicas.
5. Reimportar, executar a suíte completa e revisar capturas renderizadas.

## Critérios de aceite

- nenhum `Control` ancestral da mesa aplica escala visual;
- fontes sem antialiasing nem posicionamento subpixel;
- nenhum elemento ultrapassa 640×360;
- celular, papel, roteiro e console mantêm a composição relativa;
- suíte completa e treze capturas passam;
- inspeção das capturas mostra bordas tipográficas sem halo cinza.
