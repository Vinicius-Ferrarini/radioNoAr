# 0009 — Formato do conteúdo das noites

- **Status:** aceito
- **Data:** 2026-09-29

## Contexto

A v1 tem muito mais conteúdo por noite do que a v0: para cada noite, uma
inbox com mais itens do que os 4 blocos, cada item com afirmações
conferíveis, enquadramentos com deltas e consequências, roteiros de
teleprompter com palavras proibidas e pontos de improviso, entradas novas
de caderno. Trinta noites disso.

A v0 usa `.tres` (`data/events/event_01.tres`), com os `Choice` como
`SubResource` dentro do arquivo do evento. Funciona, mas já naquele
tamanho o arquivo é difícil de ler à mão, com ids gerados
(`Resource_yd868`) e nenhuma checagem de referência cruzada.

## Decisão

**Continuar em `.tres`**, com três ajustes:

1. **Um arquivo por noite:** `data/nights/night_NN.tres` com o
   `NightDefinition` e seus itens como `SubResource`.
2. **Recursos compartilhados como arquivos próprios**, referenciados por
   `ExtResource`, e nunca duplicados:
   - `data/notebook/entry_<id>.tres` — entradas de caderno (uma entrada
     pode ser citada por várias noites);
   - `data/consequences/<id>.tres` — `ConsequenceEffect`, referenciados
     por id a partir dos enquadramentos;
   - `data/scripts/<id>.tres` — `BroadcastScript` de teleprompter;
   - `data/rules/order_rules.tres` — as `OrderRule`.
3. **Um teste de sanidade de conteúdo** (`test_night_definitions.gd`,
   M13) que trata os dados como código: toda noite carrega; `inbox.size()
   > ProgramRundown.BLOCK_COUNT`; `propaganda_quota >= 1`; todo
   `consequence_id` e `notebook_entry_id` citado existe em disco; `IRONY`
   só aparece em item `PROPAGANDA`; `delay_nights >= 1`; toda palavra
   proibida da noite aparece em pelo menos um `ForbiddenWordSlot` de algum
   roteiro daquela noite.

## Alternativas consideradas

- **JSON (ou CSV) + carregador próprio.** Tentador: diff limpo, fácil de
  escrever em lote, sem ids gerados. Rejeitado porque perderia o editor do
  Godot como ferramenta de conteúdo (o requisito de "editável
  visualmente" vale para os dados também), perderia a validação de tipo
  que `@export` dá de graça, e obrigaria a escrever e testar um
  desserializador — código de infraestrutura que só existe para
  contornar o formato nativo.
- **Recursos aninhados num único arquivo por campanha.** Rejeitado: um
  `.tres` de trinta noites seria ingerenciável e todo conflito de merge
  cairia no mesmo arquivo.
- **`.res` binário.** Rejeitado: diff impossível de revisar.
- **Conteúdo em GDScript** (`static func night_01() -> NightDefinition`).
  Rejeitado: some do editor e mistura conteúdo com código.

## Consequências

- Os `SubResource` continuam com ids gerados pelo editor. Aceitável porque
  o que se referencia de fora é sempre `ExtResource` por caminho de
  arquivo, não o id interno.
- Escrever conteúdo à mão em `.tres` fora do editor é possível (a v0 prova)
  mas exige cuidado com `ExtResource`; qualquer erro aparece no teste de
  sanidade, não em tempo de execução.
- Renomear um id de consequência ou de entrada de caderno vira um rename de
  arquivo; o teste de sanidade pega as referências órfãs.
- Localização futura não está resolvida por este ADR: `.tres` com texto
  embutido não é traduzível sem chaves. Quando isso importar, o caminho é
  trocar os campos de texto por chaves de tradução — ADR novo, depois do
  M13.
