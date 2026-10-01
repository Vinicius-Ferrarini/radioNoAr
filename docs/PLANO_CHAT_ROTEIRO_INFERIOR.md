# Plano de implementação — chat legível e roteiro inferior

> Planejado e autorizado pelo dono em 2026-10-01 a partir de duas
> capturas do jogo. A implementação só começa depois deste documento,
> da atualização da SPEC e do ADR 0016.

**Status:** implementado e validado em 2026-10-01 — 343/343 testes,
207.530 asserts e treze capturas renderizadas até a terceira noite.

## Diagnóstico

1. A faixa bege sobre a carta de abertura vem do detalhe horizontal do
   próprio `paper_folder_panel.png`, esticado pelo `NinePatchRect`. Ela
   atravessa o corpo e parece uma sombra ou camada solta.
2. A tela do celular reserva só 58 px de altura para o histórico. As
   respostas ficam num `VBoxContainer` estreito na base e crescem além do
   corpo do aparelho quando quebram em mais de uma linha.
3. Toda reconstrução do chat força a rolagem ao final. Isso apaga a noção
   de onde começaram as mensagens novas.
4. A folha do roteiro abre no centro direito e cresce para baixo. O gesto
   não corresponde à ideia de uma folha guardada na borda da mesa.
5. `DeskLamp` e `ListenersDial` continuam ocupando o cenário, embora o
   pedido atual determine que não apareçam.

## Decisão de interface

- A carta usa um `Label` simples e uma área interna da cor do papel sobre
  o detalhe horizontal do painel. A captura renderizada mostrou que
  esvaziar o estilo do texto não bastava porque a faixa está no sprite.
- O celular continua sendo a superfície do histórico, mas fica mais largo
  e usa quase toda a altura interna para mensagens.
- Respostas e conferências aparecem num painel de decisão independente à
  direita do aparelho. O painel tem título, borda e área rolável próprias;
  nenhuma opção pode ultrapassar seus limites.
- Ao abrir uma conversa com mensagens não lidas, a primeira delas fica o
  mais alto possível. Se não houver conteúdo suficiente abaixo, o limite
  natural do `ScrollContainer` evita espaço vazio. Sem não lidas, o chat
  abre no final.
- O roteiro começa recolhido na borda inferior, imediatamente à esquerda
  de `ENTRAR NO AR`, mostrando apenas `ROTEIRO`. Clique ou pauta nova faz
  a folha crescer para cima; outro clique a guarda novamente.
- Uma resposta confirmada lança um pequeno cartão visual do celular até a
  folha enquanto o roteiro sobe. É animação de apresentação e não altera
  o estado do programa.
- `Studio/DeskLamp` e `Studio/ListenersDial` ficam sempre invisíveis.

## Ordem de implementação

1. Cobrir em teste puro o índice da primeira mensagem não lida, inclusive
   quando há falas do apresentador entre mensagens recebidas.
2. Expor esse índice por `Conversation` e usá-lo antes de marcar a thread
   como lida.
3. Reestruturar `close_phone.tscn`: corpo maior, histórico alto e painel
   externo para decisões e conferências.
4. Trocar a rolagem forçada ao fim por rolagem ao índice não lido, com
   fallback para o fim quando tudo já foi lido.
5. Cobrir o detalhe horizontal do sprite no corpo do briefing com a cor
   limpa do papel e usar um `Label` simples para o texto.
6. Reposicionar a folha, iniciar recolhida e fazer tamanho e posição
   interpolarem juntos, mantendo a abertura para cima.
7. Adicionar à mesa um cartão de transferência invisível e animá-lo da
   borda do celular ao roteiro depois de uma resposta válida.
8. Ocultar os dois elementos pedidos e remover a animação inútil da
   luminária.
9. Atualizar testes de cena para limites do painel, âncora de não lidas,
   posição do roteiro e elementos invisíveis.
10. Reimportar, rodar toda a suíte GUT e gerar capturas com renderer da
    carta, conversa, respostas, roteiro guardado e transferência.

## Critérios de aceite

- A carta não exibe retângulo ou sombra atrás do texto.
- Nenhuma resposta ultrapassa o painel de decisão ou o viewport.
- O histórico tem mais espaço horizontal e vertical que na versão atual.
- Com não lidas, a conversa abre na primeira mensagem nova; com poucas
  mensagens, não cria vazio; sem não lidas, abre no final.
- O roteiro recolhido mostra só `ROTEIRO` à esquerda de `ENTRAR NO AR`.
- Clique e pauta nova fazem a folha subir a partir da borda inferior.
- Responder mostra um cartão saindo do celular e entrando no roteiro.
- `DeskLamp` e `ListenersDial` nunca ficam visíveis.
- A suíte completa permanece verde e as capturas renderizadas confirmam
  o layout em 320×180.
