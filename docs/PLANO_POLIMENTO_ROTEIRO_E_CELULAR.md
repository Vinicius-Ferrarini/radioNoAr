# Plano de implementação — roteiro retrátil e celular por recência

> Autorizado pelo dono em 2026-09-30 a partir de três capturas do jogo.

**Status:** implementado e validado em 2026-09-30 — 339/339 testes,
207.494 asserts e onze capturas renderizadas até a terceira noite.

## Objetivo

Deixar a preparação legível sem transformar o roteiro em um painel fixo:
a folha pode ser recolhida e aberta com clique, chama atenção brevemente
quando recebe uma pauta e nunca corta a primeira linha. No celular, nome,
hora e prévia ocupam áreas independentes, e a conversa mais recentemente
atualizada vai para o topo.

## Passo a passo

1. Remover o texto de estado do teleprompter antes do ao vivo.
2. Fazer a folha inteira responder ao clique e alternar entre o cabeçalho
   compacto e a carta aberta.
3. Ao acrescentar ou atualizar uma pauta, abrir a folha, fazê-la subir
   alguns pixels e voltar; se estava recolhida, recolher novamente após a
   leitura breve.
4. Aumentar a área útil da carta e sempre zerar a rolagem quando a lista
   for reconstruída, garantindo duas entradas completas sem corte.
5. Esconder a folha atrás do briefing; ela aparece depois de `PREPARAR`.
6. Pintar o briefing como carta: título e texto em tinta escura, com uma
   hierarquia de papel, e corrigir a instrução antiga de arrastar blocos.
7. Criar uma linha própria para conversa, com colunas separadas para nome
   e hora e uma segunda linha para a prévia.
8. Registrar em `Conversation` o instante contínuo da última atividade e
   ordenar `GameState.phone_threads()` por ele, preservando a ordem da
   inbox em empates.
9. Cobrir recência, horário visível, recolhimento, lista sem corte e
   teleprompter vazio; rodar a suíte e regenerar as capturas de QA.

## Critérios de aceite

- `O microfone ainda está desligado` não aparece em nenhuma fase.
- A folha alterna aberta/recolhida pelo clique.
- Uma decisão nova produz movimento visível e revela a entrada.
- Duas pautas começam no topo da lista e aparecem inteiras; a rolagem
  antiga não corta a primeira.
- `Oficina do Portão` pode ser truncado, mas sua hora permanece inteira.
- Responder uma conversa a coloca na primeira posição da lista.
- O briefing parece tinta sobre papel e descreve o roteiro automático.
