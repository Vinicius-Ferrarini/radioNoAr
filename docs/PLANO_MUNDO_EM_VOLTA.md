# Plano — o mundo em volta

Proposta de redesenho pedida pelo dono em 2026-09-29, depois do primeiro
playtest: a dinâmica precisa mudar, ser visual em vez de texto puro, e o
jogo precisa de um mundo em volta em vez de uma mesa isolada.

**Nada aqui está decidido.** A decisão está em
`adr/0013-a-conversa-e-a-decisao.md`, com status proposto. O SPEC só
recebe a seção nova depois da confirmação, como manda o CLAUDE.md.

## Diagnóstico

Três causas concretas, todas visíveis no código de hoje.

1. **A decisão acontece duas vezes e nenhuma é diegética.** Você lê um
   parágrafo num balão com rolagem e depois escolhe um rótulo numa régua
   (`FramingStrip`). Em nenhum momento você fala com alguém. O rótulo
   ficou melhor no ADR 0011 ("Dar os parabéns" em vez de "Suavizar"), mas
   continua sendo botão de menu descrevendo uma intenção.
2. **O ao vivo é passivo.** `read_seconds` soma cerca de 16 s por bloco
   em que o único input possível é não soltar o microfone. As mecânicas
   boas do ao vivo — palavra proibida, improviso, ligação com atraso —
   aparecem uma vez cada, ou nenhuma.
3. **O mundo só existe como texto.** A consequência chega como manchete e
   carta lidas num jornal. A cidade, os ouvintes e o cerco nunca
   aparecem. A mesa é a única tela do jogo, e por isso tudo parece preso.

O que **não** é causa: a arquitetura. A lógica pura, os testes e o
pipeline de arte sobrevivem inteiros a este redesenho. O que muda é a
superfície da decisão e a existência de um lugar fora do estúdio.

## Veredito por mecânica

| # | Mecânica | Como está hoje | Veredito | O que fica no lugar |
|---|---|---|---|---|
| 1 | Ler o item | parágrafo único num balão com rolagem (`CloseItem`) | **REFATORAR** | thread de mensagens curtas, chegando uma a uma, com histórico |
| 2 | Escolher enquadramento | régua de 3–4 rótulos fora de qualquer ficção | **ELIMINAR** (a tela) | a resposta que você manda na conversa **é** o enquadramento |
| 3 | Cruzar trecho × caderno | marcar trecho, abrir caderno, escolher entrada | **MANTER** regra / **AJUSTAR** interface | arrastar a mensagem para a página do caderno; fio ligando os dois |
| 4 | Marcar "suspeito" | botão de alternar, estado invisível | **AJUSTAR** | vira anotação visível no caderno |
| 5 | Escalar 4 itens em 4 blocos | grade abstrata de slots | **AJUSTAR** | mesma regra, apresentada como a hora do programa: cartões com o rosto e a promessa feita |
| 6 | Cota de propaganda | número no cabeçalho | **MANTER** / **AJUSTAR** | cartão que o ministério deixou na sua mesa e tem de caber em algum bloco |
| 7 | Microfone e ar morto | chave + penalidade por segundo | **MANTER** | já ficou audível (ADR 0012); é o único gesto físico do jogo |
| 8 | Teleprompter | texto estático + barra, ~16 s por bloco | **REFATORAR** | varredura visível da fala e blocos de 6–8 s; o texto anda enquanto você opera |
| 9 | Palavra proibida | link invisível no texto, clicar troca | **MANTER** / **AJUSTAR** | a melhor mecânica do ao vivo; a palavra passa a se aproximar visivelmente da antena |
| 10 | Improviso com prazo | lista de opções e contagem em texto | **MANTER** / **AJUSTAR** | opções como falas curtas; prazo no ponteiro do mostrador |
| 11 | Ligação com atraso de 7 s | uma por noite, agendada | **MANTER e PROMOVER** | é o melhor do jogo e está subusado: passa a ser a espinha do ao vivo, com fila e prévia |
| 12 | Intervalo único | dois botões, 6 s | **AJUSTAR** | gesto físico (agulha no disco) e ferramenta para ganhar tempo quando algo dá errado |
| 13 | Manhã | manchete e cartas em parágrafos | **REFATORAR** | a cidade vista de cima muda: rua bloqueada, bairro escuro, gente na praça, van na porta |
| 14 | Medidores escondidos | inteiros em `Meters` | **MANTER** escondidos / **AJUSTAR** leitura | você lê pelo mundo: quem ainda liga, o que o patrocinador cobra, quem está na porta |
| 15 | Recursos (combustível, peça, dinheiro, alcance) | existem e quase não fazem nada | **AJUSTAR** ou **ELIMINAR** | só sobrevivem se sustentarem a fuga; sistema morto é pior que sistema ausente |
| 16 | Inconsistência | +1 invisível ao se contradizer | **MANTER** regra / **AJUSTAR** | um ouvinte te cobra no ar, ao vivo |
| 17 | Finais (`EndingResolver`) | existe, não ligado ao piloto | **MANTER** fora de escopo | só depois que a abertura provar o loop |
| 18 | — | — | **NOVO** | conversa com respostas: a decisão editorial dita a alguém |
| 19 | — | — | **NOVO** | cidade vista de cima: onde a consequência acontece |
| 20 | — | — | **NOVO** | locais de transmissão: estúdio, telhado, caminhonete |
| 21 | — | — | **NOVO** | fila de ligações ao vivo |

Nada é apagado em silêncio: eliminar a régua do fluxo do celular mexe em
testes existentes, e isso fica registrado no ADR 0013.

## As três mudanças estruturais

### 1. A conversa é a decisão

Absorve a régua de enquadramento. Você abre o celular, vê a thread com
histórico, as mensagens da pessoa chegam curtas, e você escolhe **o que
responder**. A resposta é que decide se aquilo vai ao ar e como — é o
mesmo `FramingOption` de hoje, exposto como fala em vez de rótulo.

Consequência de design: a apuração ganha dente. Sem evidência cruzada,
certas respostas simplesmente não existem na conversa (a regra de
`required_claim_id` já está implementada e testada).

### 2. A cidade é o medidor

Absorve a manhã. Os distritos têm estado — aceso, escuro, bloqueado,
gente na praça, van na porta — e a consequência escreve nesse estado em
vez de só produzir parágrafo. Você vê a cidade de cima e lê ali o que
fez. Os medidores continuam escondidos; o mundo é a leitura deles.

Regra para não virar mapa decorativo: **nenhum distrito entra sem uma
consequência que o mude e um efeito que volte para a mesa.**

### 3. O lugar pode mudar

Absorve a escalada. Estúdio, telhado, caminhonete: cada lugar altera
alcance, risco e ferramentas disponíveis (no telhado não há toca-discos).
A atenção do regime força a mudança. Isso dá forma física ao cerco, que
hoje é um inteiro escondido.

Regra para não duplicar a interface: **a mesma cena se re-veste por
lugar; nunca uma cena por lugar.**

## Fases

Cada fase termina com suíte verde e playtest antes da seguinte. A ordem é
por valor sobre custo, não pela ordem da ficção.

### Fase 1 — A conversa é a decisão

- **Dados:** `ChatMessage` (autor, texto curto, hora), `ReplyOption`
  (o que você manda, aponta para um `FramingOption`, pode exigir
  evidência). `BroadcastItem` ganha `thread` e `replies`.
- **Lógica pura:** `Conversation` (RefCounted) com `tick(delta)` e
  `drain_events()`, para as mensagens chegarem uma a uma sem `await`
  (ADR 0007). Teste primeiro.
- **Apresentação:** o close do celular vira thread. O esqueleto já existe
  — nome, handle, hora, avatares e balão estão na cena. Falta um
  `bubble_me` e a lista de balões.
- **Custo:** código médio-baixo, **escrita alta**: as três noites do
  piloto precisam ser reescritas em forma de conversa.
- **Prova:** a decisão deixa de ser um rótulo e passa a ser algo que você
  diz a uma pessoa. É a fase que responde ao "texto puro".

### Fase 2 — O ao vivo é um console

- Várias ligações por noite (`Array[RadioCall]` e fila), prévia e corte
  como lâmpadas; `read_seconds` de 6 a 8 s; varredura do teleprompter com
  a palavra proibida se aproximando da antena.
- **Custo:** baixo. A lógica existe; é promover, afinar dado e desenhar.
- **Prova:** o bloco deixa de ser leitura passiva.

### Fase 3 — A cidade é o medidor

- `CityState` (RefCounted) com distritos e estados;
  `ConsequenceEffect.city_changes`; a manhã aplica no mundo.
- Arte nova por primitivas: silhueta da cidade e distritos (o pipeline do
  ADR 0004 já faz isso, é script).
- Cena `scenes/city.tscn` em nós Control, visitada na manhã.
- **Custo:** alto (sistema, arte e conteúdo).
- **Prova:** consequência deixa de ser parágrafo.

### Fase 4 — Fugir

- `BroadcastSite` (Resource): alcance, risco, ferramentas. A atenção do
  regime força a mudança de lugar. A mesa se re-veste.
- **Custo:** alto.
- **Prova:** o cerco tem forma física, e a escolha passada decide de onde
  você transmite.

## O que não fazer agora

- Não escrever as 21 noites: a abertura ainda não provou o loop.
- Não começar pela cidade. Ela é a parte mais vistosa e a mais cara; se a
  conversa não segurar o jogo, um mapa bonito não segura.
- Não dublar. Legenda com leito de som já dá presença (ADR 0012).
- Não tocar em `LiveBroadcast`, `Validator` e `ProgramRundown` além do
  necessário: são a parte testada e correta do jogo.

## Riscos

- **O gargalo é escrita, não código.** Conversa boa é diálogo curto e
  específico, e são três noites para reescrever.
- **Mapa decorativo.** Mitigado pela regra da mudança 2.
- **Duas interfaces de item.** Ofícios e propaganda não têm conversa;
  precisam de superfície própria (o cartão do roteiro) para não sobrar
  régua velha no meio do fluxo novo.
- **Testes.** Eliminar a régua do fluxo do celular reescreve testes de
  cena, o que exige ADR — está no 0013.

## Validação

Cada fase se prova com uma pessoa jogando sem explicação, olhando três
coisas: ela entende o que está em risco antes de falar; ela consegue
contar depois o que aconteceu com uma pessoa específica; ela quer ver a
noite seguinte. Número de testes verde não mede nenhuma das três.
