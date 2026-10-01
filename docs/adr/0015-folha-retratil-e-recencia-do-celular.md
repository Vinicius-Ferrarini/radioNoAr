# 0015 — Folha retrátil e recência do celular

- **Status:** aceito e implementado — autorizado pelo dono em 2026-09-30.

## Contexto

O roteiro automático resolveu a duplicação da escolha, mas sua folha cobre
parte permanente da mesa, mantém a rolagem depois de atualizações e corta a
primeira pauta. A lista do celular monta nome e hora dentro do mesmo texto;
um nome comprido empurra a hora para fora. A ordem ainda é a ordem do
conteúdo, então uma resposta nova não traz a conversa de volta ao topo.

## Decisão

A folha vira uma carta retrátil clicável. Uma pauta nova abre e movimenta
a carta brevemente. A lista do celular ganha uma cena de linha com colunas
separadas e passa a ser ordenada pelo instante contínuo da última atividade
da conversa; empates preservam a ordem da inbox.

## Consequências

- A animação vive na apresentação e não decide estado do jogo.
- `Conversation` expõe apenas um número monotônico de atividade derivado do
  `GameClock` injetado, sem conhecer nós ou relógio de sistema.
- Nome pode ser truncado; hora nunca divide espaço com ele.
- A ordem visual muda quando chega ou sai uma mensagem, inclusive a resposta
  do apresentador.

Plano executável: `../PLANO_POLIMENTO_ROTEIRO_E_CELULAR.md`.
