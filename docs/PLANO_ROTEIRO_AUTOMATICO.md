# Plano de implementação — roteiro automático

> Decisão autorizada pelo dono em 2026-09-30. O roteiro passa a ser a
> consequência visível das respostas e dos carimbos dados aos papéis.
> A duração é informativa nesta fase e nunca bloqueia a transmissão.

## Objetivo jogável

Eliminar a segunda decisão de arrastar pessoas para quatro blocos. Ao
responder uma conversa, o item entra automaticamente no roteiro com o
enquadramento prometido. Carta e comunicado entram quando o apresentador
escolhe, no próprio papel, como tratá-los. O roteiro é uma folha vista de
cima, em ordem de decisão, com duração estimada e aviso de programa curto,
na medida ou longo.

## Regras

1. Resposta de celular confirma uma decisão editorial.
2. Resposta diferente de `DISCARD` acrescenta o item ao roteiro.
3. `DISCARD` permanece registrado e aparece riscado, porque recusar também
   produz consequência de manhã.
4. Papéis oferecem seus enquadramentos no próprio close; escolher um deles
   confirma e acrescenta a decisão ao roteiro.
5. Uma nova decisão entra no fim. Decidir novamente o mesmo item atualiza a
   entrada existente sem duplicá-la.
6. O roteiro aceita quantidade variável de entradas.
7. Pelo menos uma decisão completa é necessária para entrar no ar.
8. A duração estimada soma `ScriptLine.read_seconds` do roteiro escolhido.
   Descartes valem zero.
9. Menos de 24 s mostra `PROGRAMA CURTO`; de 24 a 36 s, `NA MEDIDA`; acima
   de 36 s, `PASSANDO DO HORÁRIO`.
10. Os avisos não desabilitam o botão de entrar no ar e não aplicam
    consequência nesta fase.

## Passo a passo

> **Estado:** passos 1–7 implementados em 2026-09-30. Suíte completa
> 336/336 verde; resta colher percepção de ritmo em playtest humano.

### 1. Contrato e testes da lógica

- Registrar a substituição dos quatro blocos no ADR 0014 e no SPEC.
- Cobrir `commit(item, framing)`, atualização sem duplicata, lista variável,
  descartes, cota, prontidão e efeitos de ordem.
- Preservar as APIs antigas apenas enquanto testes e cenas ainda migram.

### 2. Lista variável no núcleo

- Fazer `ProgramRundown` armazenar uma sequência variável.
- Expor `size()` e `commit()`.
- Iterar pelo tamanho real em `NightCycle`, inclusive ao abrir o ao vivo,
  resolver consequências e calcular adjacência.
- Manter ligações por posição nesta primeira entrega; posições além da fila
  continuam caindo na última entrada, comportamento já existente.

### 3. Decisão automática

- `GameState.send_reply()` confirma imediatamente o enquadramento no
  `ProgramRundown`.
- Adicionar `GameState.commit_item()` para cartas e comunicados.
- Expor uma leitura pronta para UI com remetente, promessa, descarte e
  duração estimada.

### 4. Papel de roteiro

- Criar `rundown_paper.tscn` e `rundown_paper.gd` em nós `Control`.
- Mostrar as entradas em ordem, com remetente, promessa e segundos.
- Mostrar total e aviso informativo na margem.
- Atualizar a folha sempre que `rundown_changed` for emitido.

### 5. Papéis e comunicados

- Acrescentar escolhas de enquadramento no próprio `close_item`.
- Ao clicar, confirmar a decisão, atualizar o roteiro e manter o documento
  aberto para o jogador ver o resultado.
- Respeitar `required_claim_id`; escolha ainda bloqueada não aparece.

### 6. Remover a montagem antiga

- Esconder a faixa inferior de quatro cartuchos durante a preparação.
- Remover instruções de arrastar e mensagens sobre blocos vazios.
- Fazer `ENTRAR NO AR` abrir o celular quando o roteiro estiver vazio.
- No ao vivo, usar posição real e quantidade real de entradas.

### 7. Verificação

- Migrar testes de cena que cobriam arrastar/preencher blocos para cobrir a
  nova superfície automática, sem perder as regras de cota, descarte,
  evidência e ordem.
- Rodar a suíte completa, regenerar as capturas e fazer playtest da noite 1.
- Medir: tempo até entrar no ar, quantos passos cada decisão exige e se o
  jogador entende por que cada linha apareceu no roteiro.

## Fora desta entrega

- Penalidade por programa curto ou longo.
- Limite rígido de duração.
- Reordenação das tiras no papel.
- Ligações vinculadas por `item_id` em vez de posição.
- Cidade e consequências visuais do ADR 0013.

Esses pontos ficam separados para o primeiro playtest medir o novo fluxo
sem confundir facilidade de uso com balanceamento.
