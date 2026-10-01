# 0016 — Chat legível e roteiro na borda

- **Status:** aceito e implementado — autorizado pelo dono em 2026-10-01.

## Contexto

O celular compacto do ADR 0013 deixou o histórico com pouco espaço e as
respostas de várias linhas ultrapassam o corpo do aparelho. O roteiro
retrátil do ADR 0015 funciona, mas fica aberto no centro da mesa e cresce
para baixo. O playtest também pediu que a abertura de uma conversa preserve
o começo das mensagens ainda não lidas.

## Decisão

O aparelho fica dedicado ao histórico. Respostas e conferências passam a
um painel de decisão adjacente, com limites e rolagem próprios. A conversa
abre na primeira mensagem não lida; sem não lidas, abre no final.

O roteiro fica guardado na borda inferior, à esquerda do botão de entrada
no ar, e cresce para cima. Uma resposta produz um cartão visual entre o
celular e a folha. `DeskLamp` e `ListenersDial` ficam invisíveis por decisão
visual explícita do dono.

## Consequências

- O estado de lida continua em `Conversation`; a cena apenas posiciona a
  rolagem a partir do índice informado pela lógica.
- O painel externo assume a linguagem de uma decisão editorial e deixa de
  fingir que três botões grandes cabem na tela do aparelho.
- A animação de transferência e a abertura da folha permanecem na camada
  de apresentação.
- A parte da atmosfera do ADR 0012 que animava a luminária deixa de ser
  visível; som, letreiro e telefone continuam ativos.

Plano executável: `../PLANO_CHAT_ROTEIRO_INFERIOR.md`.
