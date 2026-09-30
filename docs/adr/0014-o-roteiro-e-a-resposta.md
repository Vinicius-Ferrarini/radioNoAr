# 0014 — O roteiro é a resposta

- **Status:** aceito — autorizado pelo dono em 2026-09-30.

## Contexto

Depois do redesenho visual, o playtest ainda identificou uma duplicação:
responder uma pessoa decide o enquadramento, mas o jogador precisa arrastar
a mesma pessoa para um dos quatro blocos. A montagem ocupa a parte inferior
da tela e transforma uma promessa feita na conversa em trabalho de menu.

## Decisão

`ProgramRundown` passa de quatro posições obrigatórias para uma sequência
variável de decisões. Responder no celular confirma automaticamente a
entrada; papéis são confirmados no próprio documento. `DISCARD` fica na
sequência como decisão registrada, mas não vai ao ar.

O roteiro é mostrado como uma folha sobre a mesa. Sua duração estimada é a
soma de `ScriptLine.read_seconds`. Os estados curto, na medida e longo são
informativos: não bloqueiam o ar e ainda não têm consequência.

A ordem inicial é a ordem das decisões. Reordenação fica fora desta entrega
para que o playtest avalie primeiro o fluxo automático.

## Alternativas consideradas

- **Preencher automaticamente quatro blocos ocultos.** Exigiria tratamento
  especial quando a quinta decisão chegasse e manteria a regra que causou o
  atrito.
- **Manter arrastar como etapa opcional.** Ainda deixaria duas superfícies
  concorrendo pela mesma decisão.
- **Aplicar punição de duração agora.** Adiaria a validação principal e
  misturaria qualidade do fluxo com balanceamento ainda não testado.

## Consequências

- A parte de `ProgramRundown` do SPEC e os testes que exigem quatro blocos
  são substituídos por testes de sequência variável.
- `NightCycle` percorre o tamanho real do roteiro.
- `RadioCall.block_position` continua funcionando por posição nesta fase.
- Efeitos de ordem continuam valendo entre decisões consecutivas que vão ao
  ar; descartes quebram a adjacência.
- A recusa continua produzindo consequências na manhã.
- A faixa visual de quatro cartuchos deixa a preparação.

Plano executável: `../PLANO_ROTEIRO_AUTOMATICO.md`.
