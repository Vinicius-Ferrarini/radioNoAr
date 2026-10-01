# Plano — resolução e sprites em densidade 2×

## Objetivo

Levar `No Ar` à densidade visual de `Papers, Please` sem deformar o grid de
pixel art. A interface lógica continua sendo composta em 320×180 unidades,
mas passa a ser renderizada num canvas nativo de 640×360.

## Decisão de escala

`Papers, Please` usa 570×320. Aplicar essa medida diretamente sobre a base
320×180 exigiria escalas fracionárias diferentes em cada eixo. O projeto
adota 640×360 porque é um múltiplo inteiro exato de 320×180, mantém 16:9 e
fica ligeiramente acima da densidade do jogo de referência.

- canvas nativo: 640×360;
- janela padrão: 1280×720, escala inteira 2×;
- composição lógica: 320×180 escalada exatamente 2×;
- assets rasterizados: fontes 2×, preservando o grid original;
- retratos prioritários: 64×64 de fonte para ocupar o mesmo espaço lógico
  dos antigos 32×32 com quatro vezes mais pixels disponíveis.

## Etapas

1. Registrar no SPEC e no ADR 0020 a substituição da base do ADR 0005.
2. Criar uma cena-raiz 640×360 que hospeda a mesa lógica em escala 2×.
3. Atualizar configuração, testes de resolução e roteiro de captura.
4. Fazer o pipeline exportar fontes rasterizadas em densidade 2×.
5. Manter tamanhos lógicos das cenas; a textura 2× é amostrada 1:1 no canvas.
6. Adicionar microdetalhes de um pixel de fonte aos cinco retratos principais.
7. Regenerar, importar, executar a suíte completa e revisar as treze capturas.

## Critérios de aceite

- canvas nativo 640×360 e janela 1280×720 em escala inteira;
- nenhuma escala fracionária no contêiner da mesa;
- os cinco retratos da primeira noite têm 64×64 pixels de fonte;
- todos os sprites do manifesto têm exatamente o dobro da dimensão lógica;
- controles continuam dentro da composição lógica 320×180;
- suite GUT e percurso renderizado completos.

## Resultado — 2026-10-01

- Canvas 640×360 e janela 1280×720 implementados por `game_canvas.tscn`.
- Mesa lógica preservada em 320×180 com escala uniforme exata de 2×.
- Todos os 47 sprites regenerados com o dobro de largura e altura.
- Cinco retratos principais em 64×64 com microdetalhes próprios na fonte.
- Corrigida a visibilidade real do contêiner de closes, encontrada na revisão
  das capturas.
- Suíte **353/353**, com **921.594 asserts**, e treze capturas concluídas.
