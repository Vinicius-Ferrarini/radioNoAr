# 0013 — A conversa é a decisão; a cidade é o medidor

- Status: **aceito** — confirmado pelo dono em 2026-09-29, com execução
  autorizada a começar pela Fase 1. As fases 2 a 4 seguem propostas e
  dependem do playtest de cada anterior.

## Contexto

Segundo playtest do dono, 2026-09-29, depois da passada de atmosfera do
ADR 0012: som e movimento ajudaram, mas a dinâmica continua de texto puro
e o jogo "parece muito preso". O pedido é explícito: mudar a dinâmica,
ser visual, e ter um mundo em volta — o exemplo dado foi o telefone que
abre a conversa com histórico e respostas, onde a resposta decide se
aquilo vai ao ar, mais uma cidade vista de cima e a possibilidade de ter
de fugir e transmitir de outro lugar.

O diagnóstico e o plano de execução estão em `../PLANO_MUNDO_EM_VOLTA.md`.

## Decisão proposta

Três mudanças estruturais, em fases, cada uma com playtest antes da
seguinte.

1. **A conversa é a decisão.** O close do celular vira thread com
   histórico; a decisão editorial passa a ser a resposta que você manda
   para a pessoa. A régua de enquadramento sai do fluxo do celular. O
   dado por baixo continua sendo `FramingOption`, incluindo a exigência
   de evidência cruzada de `required_claim_id`.
2. **A cidade é o medidor.** A manhã deixa de ser lista de parágrafos e
   passa a ser o estado de distritos que a consequência altera. Os
   medidores continuam escondidos e passam a ser lidos pelo mundo.
3. **O lugar pode mudar.** Estúdio, telhado e caminhonete alteram
   alcance, risco e ferramentas. A atenção do regime força a mudança.

Mecânicas eliminadas, ajustadas e mantidas estão tabeladas no plano. Duas
decisões incômodas ficam explícitas aqui:

- **A régua de enquadramento morre como tela** do fluxo de celular. Isso
  reescreve testes de cena existentes, o que o CLAUDE.md só permite com
  ADR: é este. Nenhum teste é apagado em silêncio; os de regra de
  `ProgramRundown` continuam valendo, porque a regra não muda.
- **Os recursos** (combustível, peça, dinheiro, alcance) ou passam a
  sustentar a fuga, ou saem do escopo da abertura. Sistema que existe e
  não faz nada é pior que sistema ausente.

## Alternativas

- **Só continuar polindo atmosfera.** Rejeitada pelo próprio playtest: o
  problema relatado é a dinâmica, não o acabamento.
- **Começar pela cidade**, que é o pedido mais vistoso. Rejeitada como
  primeira fase: é a mais cara e não resolve o texto puro. Se a conversa
  não segurar o jogo, mapa bonito não segura.
- **Refazer a arquitetura.** Desnecessária. A lógica pura, os testes e o
  pipeline de arte atravessam este redesenho intactos; o que muda é a
  superfície da decisão.
- **Adicionar ação em tempo real ao ao vivo** (minijogo de dial, mixagem).
  Fora de escopo por ora: a tensão que o jogo já tem e não usa é a
  ligação com atraso de sete segundos.

## Consequências

O SPEC ganha uma seção nova quando isto for aceito — não antes, como
manda o CLAUDE.md. A abertura de três noites do ADR 0011 precisa ser
reescrita em forma de conversa; o conteúdo atual em `data/pilot/` vira
base de texto, não formato final. O gargalo passa a ser escrita de
diálogo, não código. As 21 noites continuam bloqueadas até a abertura
provar o loop com playtest.
