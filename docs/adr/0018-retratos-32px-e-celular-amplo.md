# 0018 — Retratos 32 px e celular amplo

- **Status:** aceito e implementado — autorizado pelo dono em 2026-10-01.

## Contexto

Os retratos 20×20 do ADR 0017 identificam os contatos, mas não preservam a
personalidade da referência visual. O espaço é insuficiente para rosto,
roupa, iluminação e cenário, e o cabeçalho atual reduz o retrato ainda mais.

## Decisão

Os cinco contatos telefônicos da primeira noite usam retratos 32×32 nativos.
O aparelho cresce para 156×166, as linhas da lista para 38 px e a conversa
ganha uma faixa de contato com retrato, nome e identificação. O botão de
fechar passa à faixa superior da moldura. As respostas continuam no painel
externo.

Os sprites continuam gerados por `sprite_defs`, limitados à paleta e
versionados com manifesto. A folha conceitual orienta composição e
personalidade, mas não entra diretamente no jogo.

## Consequências

- Três contatos ficam inteiros na lista; os demais dependem da rolagem.
- O histórico preserva aproximadamente a altura anterior porque o aparelho
  também cresce.
- O custo de arte aumenta: retratos passam a ser pequenas ilustrações, não
  ícones formados por poucos blocos.
- A resolução base, o filtro nearest e a arquitetura de apresentação não
  mudam.

O ADR 0020 preserva posteriormente a área lógica 32×32, mas aumenta a fonte
rasterizada desses retratos para 64×64.

Plano executável: `../PLANO_RETRATOS_32PX_E_CELULAR_AMPLO.md`.
