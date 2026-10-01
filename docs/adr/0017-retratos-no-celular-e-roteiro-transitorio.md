# 0017 — Retratos no celular e roteiro transitório

- **Status:** aceito e implementado — autorizado pelo dono em 2026-10-01.

## Contexto

O celular já organiza conversas por atividade, mas ainda apresenta apenas
texto. Isso reduz a personalidade dos remetentes e obriga o jogador a reler
nomes para reconhecer uma conversa. Os balões com ponta lateral produzem uma
saliência visual indesejada quando a textura é esticada. A aba recolhida do
roteiro também perde contraste sobre a mesa, e a abertura automática após uma
resposta permanece aberta mesmo quando o jogador a havia guardado.

## Decisão

Os cinco contatos telefônicos da primeira noite recebem retratos próprios,
gerados pelo pipeline determinístico de pixel art. A lista mostra o retrato em
uma coluna reservada e a conversa o repete no cabeçalho. A oficina usa uma
imagem do local em vez de um rosto.

Os balões passam a caixas retangulares de `StyleBoxFlat`, sem cauda nem pixels
fora do retângulo do controle. A aba recolhida do roteiro recebe texto e borda
claros. Uma decisão abre temporariamente a folha e a recolhe depois da
transferência somente quando ela estava recolhida antes da decisão.

## Consequências

- O nome do asset do avatar passa pela projeção de leitura de
  `GameState.phone_threads()`; nenhuma regra de jogo depende da textura.
- As linhas da lista ficam mais altas e mostram menos conversas simultâneas,
  compensadas pela rolagem já existente.
- A distinção entre fala recebida e resposta continua pelas cores e pelo
  alinhamento, sem depender de uma cauda decorativa.
- A escolha manual do estado aberto do roteiro prevalece sobre a animação.

Plano executável: `../PLANO_RETRATOS_E_ACABAMENTO_DO_CELULAR.md`.
