# No Ar — Estado do projeto

## Atualização: abertura Rádio viva (2026-09-29)

**Agora há três noites jogáveis em sequência**, selecionadas por padrão
ao executar o projeto. O instantâneo original abaixo descreve o estado
anterior e permanece como histórico, não como orientação atual de escopo.

- **Noite 1:** aniversário, futebol, oficina, chave perdida e uma ligação
  bem-humorada. Sem cota política. Conferir a súmula desbloqueia correção.
- **Noite 2:** boletim e vistoria da ponte se contradizem. A ligação de
  Rui pode ser cortada ou transmitida, com repercussões diferentes.
- **Noite 3:** a mensagem de Rui muda conforme seu nome foi transmitido.
  Favores oficiais e comunitários trazem condições; a última manhã
  encerra a abertura e permite recomeçar.

Controles: clique no microfone ou ESPAÇO alterna ligado/desligado;
**C** corta a prévia de sete segundos. Música ou anúncio usa a única
reserva de seis segundos da noite e segura a prévia. Música gera vínculo
e um disco na mesa; anúncio rende $8 e um letreiro. Depois do último
bloco, **MANHÃ** abre as repercussões. O caderno continua acessível ao vivo.

Conteúdo novo: `data/pilot/`, roteiros `data/scripts/p*.tres`, consequências
`data/consequences/p_*.tres`. O cenário antigo de `data/nights/` é mantido
para testes de regressão. A escolha do catálogo fica em `GameState`.

Assets: 35 sprites no manifesto (8 novos), 6 WAVs originais sintetizados
em `assets/audio/`. Fontes em `tools/pixelart/sprite_defs/` e
`tools/audio/generate.gd`. Sem dublagem: as falas ainda são legendadas.

Validação: **282 testes passando**, 83.878 asserts. Inclui os
dois caminhos das três noites, investigação, reserva limitada, corte e
controles da mesa. `tools/qa/capture_radio.gd` percorre a UI com renderer
e grava sete capturas em `.godot/radio-qa/`. O modo Dummy desse roteiro
não avalia som por audição. Diversão e ritmo precisam de playtest humano.

Plano e decisões: `PLANO_RADIO_VIVA.md`, SPEC (revisão inicial) e ADR 0011.
Fase de dia completa, campanha longa, finais, opções e salvamento seguem
pendentes. Não interpretar as três noites como a campanha final pronta.

## Atualização: redesenho em curso (ADR 0013)

**Fase 1 — a conversa é a decisão.** O celular é um aparelho em pé: data
(15/07/2008 na noite 1), relógio que começa às 19:00 e anda com a noite,
lista de conversas com a hora da última fala e quantas não lidas, e dentro
de cada uma os balões chegando um a um. **A resposta que você manda é o
enquadramento**: ao escalar a pessoa, o bloco herda o que você disse a
ela. A régua de enquadramento ficou só para papel (carta e ofício).

As mensagens correm sozinhas desde o começo da noite — abrir o aparelho
não dispara nada. Toda fala é marcada pelo relógio na entrega, então a
ordem das horas é a ordem de chegada. As **onze conversas das três
noites** estão escritas; nenhuma é sintetizada.

Resposta que exige apuração não aparece como opção: as fichas
conferíveis ficam na própria conversa, com o trecho palavra por palavra.

**Fase 2 — o ao vivo é um console.** A noite tem várias ligações, cada uma
com seu bloco e seu gatilho, e **a linha atende uma por vez**: quem chega
com a linha ocupada espera na fila e entra quando ela vaga, por corte ou
por ir ao ar. O console mostra três lâmpadas — livre, prévia, no ar — mais
quantas esperam. Nenhuma ligação se perde na virada de bloco.

O teleprompter ganhou varredura: uma cópia escurecida por cima revela até
onde a leitura chegou. E ela tem dente — **a palavra proibida vai ao ar
quando a leitura passa por ela**, não no fim da linha. A noite 2 declara a
circular da semana no caderno ("interditada", termo aceito "com tráfego
alterado") e a palavra aparece em dois roteiros: trocar depois que a
varredura passou não evita a infração.

Fases 3 (a cidade é o medidor) e 4 (fugir) seguem propostas, cada uma
dependendo do playtest da anterior. Plano, tabela de mecânicas e
validação: `PLANO_MUNDO_EM_VOLTA.md`.

### Atmosfera (ADR 0012)

O estúdio tem leito de som contínuo: zumbido sempre presente e estática
que sobe no ar morto (−11 dB) e recua no ar (−34 dB). A mesa se move —
letreiro AO AR pulsando conforme o que está saindo pela antena, lâmpada
oscilando, telefone tremendo enquanto a ligação espera no atraso de sete
segundos. Tudo em `_breathe()`, só apresentação, sem `_draw`.

Dois WAVs novos em loop (`room_tone`, `radio_static`), gerados por
`tools/audio/generate.gd` com semente fixa. O loop vem de
`edit/loop_mode=2` no `.import` e tem teste próprio: leito sem loop toca
uma vez e emudece a mesa sem ninguém notar.

Entrar no ar: o botão **ENTRAR NO AR** (embaixo à direita) nunca fica
desabilitado e nunca fica calado — se o programa não está pronto, diz o
que falta e abre o celular ou a régua de enquadramento do bloco pendente.

### Pontas conhecidas da abertura

Coisas que parecem esquecimento e são decisão. Quem for mexer, leia antes.

- **`data/nights/night_01.tres` continua sem `label` e sem
  `required_claim_id`.** É o cenário de regressão do estado anterior
  (ADR 0011): a fala "Contar a verdade" ali ainda vai ao ar sem apuração.
  Não usar esse arquivo como referência de conteúdo novo; o formato atual
  é o de `data/pilot/`.
- **A noite 3 não tem apuração — nem claim, nem item fraudulento, nem
  enquadramento TRUTH.** É de propósito: as noites 1 e 2 ensinam a cruzar
  o caderno, e a 3 cobra a decisão sobre o que já se sabe. Se um item
  investigável entrar ali depois, ele precisa de `required_claim_id`.
- **Os roteiros Python que geraram `data/pilot/`, os `sprite_defs/` novos
  e os nós da mesa foram andaimes de uso único** e ficaram em `.godot/`,
  que não é versionado. As saídas são a fonte de verdade e estão
  versionadas. **Não reexecutar** `build_radio_scene.py`: ele aplica um
  patch não idempotente e duplicaria nós em `scenes/studio_desk.tscn`.
  Dali para frente a mesa se edita no editor do Godot ou à mão.

---

## Instantâneo anterior (antes da revisão Rádio viva)

> Instantâneo de **2026-09-29**, depois do M10. Serve para quem (ou qual
> sessão) pegar o projeto do zero se orientar em cinco minutos: o que
> existe, onde está, e o que falta.
>
> Documentos vizinhos: `GAME_DESIGN.md` (o jogo), `SPEC.md` (a fonte de
> verdade técnica), `ROADMAP.md` (status dos marcos), `adr/` (as decisões
> e por que foram tomadas).

---

## 1. O jogo em três frases

Você é o último apresentador de uma rádio livre num país fictício com o
cerco apertando, e tem 21 noites até o referendo. A cada noite chegam
mais itens do que cabem no programa: você confere o que é mentira
cruzando com o seu caderno, escolhe o que vai ao ar e como, e apresenta
ao vivo segurando o microfone. **A conta chega sempre de manhã, nunca na
hora** — e nenhuma escolha é rotulada como a certa.

---

## 2. Como rodar

```
# jogar
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --path C:\github\radioNoAr

# testes (tem que estar 100% verde antes de fechar qualquer marco)
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit

# reimportar (obrigatório depois de criar/editar script com class_name fora do editor)
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless --import

# regerar a pixel art (obrigatório depois de mexer em qualquer definição de sprite)
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s tools/pixelart/generate.gd

# conferir um sprite sem abrir o editor
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s tools/pixelart/preview.gd -- window_night
```

---

## 3. O que dá para jogar hoje

**A noite 1, de ponta a ponta.** Só ela.

1. **Triagem.** A mesa do estúdio com o celular, a pilha de cartas e o
   caderno. Clicar abre cada um em close: o celular em tela azul com
   bolhas, hora e foto de perfil; a carta em papel creme com lacre; o
   comunicado oficial em papel acinzentado com carimbo.
2. **Conferir.** Marcar um trecho de um item abre o caderno; clicar numa
   linha cruza os dois e responde `CONTRADIÇÃO`, `confere` ou `não tem
   relação`. Dois itens da noite 1 são verdadeiros e o caderno **não
   alcança** — de propósito.
3. **Escalação.** Arrastar a foto da pessoa para um dos 4 blocos. O bloco
   1 é o de cota, com moldura tracejada. Clicar num bloco abre a régua de
   enquadramento.
4. **Ao vivo.** Segurar o microfone (ou ESPAÇO) faz o teleprompter subir.
   Soltar é ar morto, a 2 ouvintes por segundo. Palavras proibidas estão
   escondidas no texto sem destaque; clicar troca pelo sinônimo aprovado.
   O roteiro para em pontos de improviso com relógio contando — deixar
   estourar escolhe a opção mais covarde.
5. **Manhã.** O jornal com as manchetes, os bilhetes que chegaram na
   porta, e o que o caderno aprendeu. É aqui que você descobre o preço.

Depois da manhã da noite 1 o botão fica `FIM`: **a noite 2 ainda não foi
escrita.** Isso é falta de conteúdo (M13), não de mecânica.

---

## 4. Mapa do repositório

| Onde | O que |
|---|---|
| `scripts/core/*.gd` | **Lógica pura** (11 arquivos). `RefCounted`, sem `Node`, sem relógio, sem sorteio global |
| `scripts/core/data/*.gd` | **Dados** (14 Resources). Só `@export`, nunca comportamento |
| `scripts/game_state.gd` | O **autoload**: a única ponte entre lógica e cenas, e o único `_process` do projeto |
| `scenes/studio_desk.tscn` | A mesa — a casa do jogo, nunca sai da tela |
| `scenes/parts/*.tscn` | Os closes e peças reutilizáveis (celular/carta, caderno, régua de enquadramento, improviso, manhã, linha de lista, bloco do programa) |
| `data/nights/`, `senders/`, `notebook/`, `consequences/`, `scripts/`, `rules/` | **Conteúdo**, tudo em `.tres` (ADR 0009) |
| `tools/pixelart/` | Paleta, gerador determinístico, previsualizador ASCII, e as definições de sprite em texto |
| `assets/sprites/` | 27 PNGs versionados + `manifest.json` com sha256 |
| `tests/unit/` | 21 arquivos de teste GUT |
| `docs/adr/` | 10 ADRs — leia antes de discordar de alguma decisão |

---

## 5. Arquitetura em uma página

**Três camadas, sem exceção:** Dados (`Resource`) → Lógica pura
(`RefCounted`) → Apresentação (cenas que só escutam sinais do autoload).

Cinco regras que **têm teste cobrando**, não são boa intenção:

| Regra | Quem cobra |
|---|---|
| Lógica pura não conhece `Node`, `Time`, `Timer`, `randi()`, `Input`, `get_tree`, `signal` | `test_pure_logic_is_node_free.gd` |
| Cena não instancia lógica, não lê `is_fraudulent`, não abre `res://data/` | `test_scenes_do_not_own_logic.gd` |
| Nenhum `_draw()` em lugar nenhum da UI | `test_no_custom_draw.gd` |
| Medidor escondido nunca chega na UI | `test_game_state_v1.gd`, `test_night_one_run.gd` |
| Todo pixel de todo sprite é uma cor da paleta, e a arte não está fora de data | `test_asset_manifest.gd` |

**Os seis medidores** (ADR 0002): confiança da audiência e temperatura
das ruas e alinhamento são visíveis; **atenção do regime, integridade e
inconsistência são escondidos** — o regime não tem medidor, só sinais
vagos.

**Tempo e sorteio injetados** (ADR 0007): o ao vivo roda por
`tick(delta)` e a mesma seed dá a mesma noite. É isso que faz a mecânica
mais complexa do jogo testar headless em milissegundos.

---

## 6. Números

| | |
|---|---|
| Testes | **265, todos passando** (~21 700 asserts, ~9 s) |
| Linhas de GDScript (sem addons) | ~4 150 |
| Módulos de lógica pura | 11 |
| Resources de dados | 14 |
| Cenas | 8 |
| Sprites | 27, gerados por script, determinísticos |
| Conteúdo | 1 noite · 6 remetentes · 7 entradas de caderno · 10 consequências · 16 roteiros · 4 regras de ordem |
| Documentação | ~1 200 linhas + 10 ADRs |
| Marcos concluídos | M4 a M10 (7 de 12) |

---

## 7. O que falta — por marco

### M8C — Tela de título, opções e transições `pequeno`

O jogo começa no meio: não existe menu. Falta:

- `scenes/main_menu.tscn`: título, **ENTRAR NO AR**, **OPÇÕES**, **SAIR**.
- Tela de opções: tela cheia, escala da janela, velocidade de texto.
  *Volume fica para o M14, porque ainda não existe áudio.*
- Transições de fade entre menu ↔ mesa (a v0 tinha isso e morreu com ela).
- `main_scene` passa a ser o menu.
- **Sem salvar**, decidido: a campanha de 21 noites ainda não existe para
  ser salva, e o formato do save vai mudar com a fase de dia e os finais.

### M9½ — Buracos deixados pelo ao vivo `pequeno, mas incômodo`

Três coisas do design estão **especificadas e testadas na lógica, mas
sem gatilho no jogo**:

- **A ligação com delay de 7 s.** `queue_call()` e `cut_call()` existem,
  estão testados, e o autoload expõe `cut_call()` — mas **nada chama
  `queue_call`**: não há conteúdo de ligação nem botão de corte na tela.
  É a mecânica mais dramática do ao vivo e hoje é código morto.
- **Trilha entre blocos** (escolher a música é mandar sinal, com os
  códigos no caderno). Não existe: nem lógica, nem conteúdo. O caderno da
  noite 1 já tem a entrada `valsa_no_fim` esperando por ela.
- **Eventos ao vivo**: queda de energia, interferência no dial, batida na
  porta, ouvinte em perigo. Nenhum implementado.

### M11 — Fase de dia `médio`

Especificado no SPEC §4.7, **nada implementado**. Falta:

- `DayPhase` (lógica pura): atribuir tarefas, resolver com o RNG
  injetado, devolver deltas de recurso e quem foi preso.
- `CrewMember` (Resource) + conteúdo: O Técnico e os outros.
- O close da fase de dia, e a UI dos recursos (combustível, peças,
  dinheiro, alcance).
- `NightCycle.day()`, hoje ausente.
- Regra desenhada e ainda não escrita: mais alcance = triangulação mais
  fácil = mais atenção do regime.

### M12 — Finais país × pessoal `médio`

- `EndingResolver` v2: `EndingResult`, `resolve_country`,
  `resolve_personal`. Hoje o arquivo ainda tem a assinatura v0
  `resolve(power: int)`, que sobreviveu intacta ao M10.
- A cena de final, que foi removida no M10 e precisa ser reconstruída.
- Os textos: 4 destinos de país × 4 destinos pessoais, com os 7 finais da
  v0 remapeados (a tabela está no `GAME_DESIGN.md` §11).
- Ligar as `flags_set` das consequências ao resolvedor — elas já estão
  sendo gravadas em `RunState`, e ninguém lê ainda.
- Teste de fronteira para cada limiar da SPEC §4.9.
- **Devolve a garantia perdida no M10:** nenhum teste leva hoje uma
  campanha até um final (registrado no ADR 0003).

### M13 — Conteúdo das 21 noites `o maior volume de trabalho do projeto`

Existe **1 noite de 21**. Falta:

- 20 `night_NN.tres`, cada uma com 5–7 itens → **~120 itens**.
- Um roteiro de teleprompter por enquadramento que vai ao ar. A noite 1
  precisou de 16; escalando, são **~300 roteiros**.
- Consequências, entradas de caderno e palavras proibidas de cada noite.
- **O corte da internet**: a partir de certa noite o `era` vira
  `LETTERS`, o celular some da mesa e só restam cartas e telefone fixo.
  A UI para essa era não existe.
- A escalada da cota de propaganda (1 → 2 → 3).
- Os arcos dos personagens recorrentes: Dona Célia, O Técnico, O Contato,
  A Líder da Oposição, O Âncora da TV estatal. Hoje só a Célia e o
  Toledo existem como gente.
- `test_night_definitions.gd` estendido para todas as noites (ele já está
  escrito para crescer: é só a lista `NIGHT_PATHS`).

### M14 — Som e polimento `médio`

- Áudio: nada existe. Nenhum `AudioStreamPlayer` no projeto.
- Ruído de dial, estática, telefone, o som do ar morto.
- A trilha como sinal para a resistência (ver M9½).
- **A cor se esvaindo** conforme o cerco aperta: o ADR 0008 decidiu como
  (`CanvasModulate` + estágio discreto), e `RunState.siege_stage()` não
  existe. A paleta já tem o mapa `FADED` pronto e sem uso.
- Passada de legibilidade em 320×180 (ver riscos).

---

## 8. Decisões que dependem do designer

Nenhuma delas bloqueia o M8C, o M11 ou o M12.

1. **Em que noite a internet cai?** Proposta: noite 11, o meio exato.
   Resposta necessária no M13.
2. **Dá para perder antes do fim** — rádio destruída, prisão, audiência
   zerada — ou a campanha sempre chega ao referendo? Afeta M11 e M12.
3. **A cota de propaganda pode chegar a 4**, com o programa inteiro do
   governo, em alguma noite tardia? Ou o teto é 3?

---

## 9. Riscos e dívidas conhecidas

| | |
|---|---|
| **Legibilidade em 320×180** | O risco previsto no ADR 0005 ainda não foi julgado com o jogo na mão. Se o texto das cartas estiver apertado, a saída já está escrita: 480×270, que são duas linhas no `project.godot` e os tamanhos do Theme |
| **O ritmo do ao vivo nunca foi jogado de verdade** | `read_seconds` e `time_limit_seconds` foram chutados por mim. Estão em dados, então calibrar é trivial — mas alguém precisa jogar e dizer |
| **Volume de conteúdo do M13** | ~120 itens e ~300 roteiros é, de longe, o maior esforço restante. O teste de sanidade de conteúdo existe justamente para que conteúdo quebrado não passe em silêncio |
| **`ironizar` não tem risco implementado** | O design diz "risco se o regime decifrar". Hoje ironizar só soma atenção do regime; não há mecânica de ser decifrado |
| **Branch `main` ainda existe** | Passo manual no GitHub: trocar a branch padrão para `master` antes de apagar `main` (ADR 0001) |

---

## 10. Correções de modelo que já aconteceram

Ficam registradas porque foram erros meus de leitura do design, e o
padrão pode se repetir:

- **M6** — a `condition` da consequência era resolvida na manhã; passou a
  ser resolvida na hora de agendar, onde já se sabe tudo o que ela
  pergunta.
- **M8** — o botão AO AR avançava uma fase só, de triagem para escalação,
  e para o jogador nada acontecia. Triagem e escalação são a mesma tela.
- **M8B** — a interface funcionava e não era o jogo: um painel de abas
  cobrindo a mesa, com carta e mensagem de celular pintadas igual. Virou
  o ADR 0010.
- **M9** — o ao vivo lia um id de medidor, quebrando a própria regra de
  que ele não toca em `Meters`. E o microfone "caía da mão" ao emendar um
  bloco no outro.
- **M10** — a `ConsequenceQueue` vencia **uma manhã tarde demais**: a
  manhã da noite 1 vinha vazia e o jogador terminava o programa sem ver o
  preço. Só apareceu ao montar a fatia vertical inteira; nenhum teste
  unitário pegaria, porque todos concordavam com o modelo errado.

A lição prática: **rodar o jogo e olhar**, não só a suíte verde.

---

## 11. Como continuar

O processo está no `CLAUDE.md` e vale sempre:

1. A mecânica entra primeiro no `SPEC.md`, com critério de aceite.
2. Teste GUT que falha → código mínimo → refatorar.
3. Decisão de arquitetura, formato ou escopo vira ADR em `docs/adr/`.
4. Marco só fecha com a suíte **inteira** verde headless **e** com o jogo
   rodando e olhado.
5. Nenhum teste é apagado em silêncio: reescrever teste é decisão
   registrada em ADR.

Ordem sugerida daqui: **M8C** (rápido, tira o jogo de começar no meio) →
**M11** → **M12** (devolve a garantia de final) → **M13** (o volume) →
**M14**. O M9½ pode ser encaixado junto do M14, ou antes, se a ligação ao
vivo for considerada essencial para o jogo se provar.
