# Prompt para o Claude Code — No Ar: plano da v1

> Cole tudo abaixo da linha no Claude Code, com o repositório aberto na branch `master`.

---

Você vai PLANEJAR (não implementar ainda) a evolução do jogo **No Ar** da v0 atual para a v1 descrita abaixo. Leia primeiro `CLAUDE.md`, `docs/GAME_DESIGN.md`, `docs/SPEC.md` e todo o código em `scripts/`, `scenes/`, `data/` e `tests/`. As regras do `CLAUDE.md` continuam valendo (SDD, TDD com GUT, 3 camadas, sem `_draw()`, um marco por vez).

Nesta sessão, entregue só documentação e plano. Não escreva código de gameplay. No fim, pare e me mostre o plano para aprovação.

## 0. Estado atual do repositório (confirme antes de tudo)

- O trabalho está na branch `master` (M0–M3 concluídos). A branch `main` tem só um `.gitignore` do Godot, sem histórico em comum com `master`. Me pergunte qual branch deve virar a principal antes de mexer em branches.
- Em `master` não existe `.gitignore`, e a pasta `.godot/` (cache do editor, shaders, imports) está versionada. Proponha trazer o `.gitignore` e remover `.godot/` do versionamento (`git rm -r --cached .godot`), registrando isso num ADR.
- Rode a suíte GUT headless e me mostre a saída, para termos a linha de base verde antes de qualquer mudança.

## 1. Visão da v1 (fonte para reescrever `docs/GAME_DESIGN.md`)

Premissa mantida: país fictício, governo autoritário apertando o cerco, povo pedindo eleições; você é o último apresentador de uma rádio livre. Sem partidos ou políticos reais. Contagem regressiva de ~30 noites até o referendo. A consequência de cada escolha só aparece na manhã seguinte, nunca na hora. Nenhuma escolha é rotulada como "a certa": a verdade pode ser armadilha, acalmar pode salvar vidas, inflamar dá poder real e pode te transformar no próximo demagogo.

### Loop de uma noite
1. **Noite (triagem):** chegam mais itens do que cabem no programa, pelo celular, por cartas e como propaganda oficial. Você lê e valida cada um.
2. **Escalação:** arrasta itens para os 4 blocos do programa. A ordem importa (propaganda logo depois de uma denúncia soa como ironia). Exemplo da noite 1: 2 mensagens de celular, 1 carta, 1 propaganda.
3. **Enquadramento:** escolhe como apresentar cada item.
4. **No ar:** apresenta ao vivo (mecânica abaixo).
5. **Manhã:** manchetes, cartas e bilhetes mostram as consequências da noite anterior, às vezes de forma ambígua.
6. **Dia:** gestão de recursos e equipe (estilo 60 Seconds), depois a próxima noite.

### Itens e quem os envia
| Tipo | O que pede | Ganho | Custo |
|---|---|---|---|
| Suborno | Dinheiro para falar ou calar algo | Combustível, peças, segurança | Credibilidade cai se descobrirem |
| Vendedor | Troca uma peça | Conserta o transmissor | Peça pode ser roubada ou grampeada |
| Vingança | Expor alguém no ar | Pode desmascarar um informante | Pode ser briga de vizinho |
| Quer aparecer | Espaço no ar | Audiência, às vezes mensagem codificada | Ocupa um bloco |
| Pedido de ajuda | Dizer o nome de um desaparecido | Pressão pública protege | Pode condenar a pessoa |
| Propaganda oficial | Obrigatória (cota) | Evita atenção do regime | Um bloco a menos para o povo |

**Cota de propaganda:** mínimo de blocos oficiais por programa, crescendo com as noites (1 → 2 → 3). Recusar atrai atenção.

### Enquadramentos
Ler como chegou · Contar a verdade · Suavizar · Inflamar · Ironizar (só propaganda; mensagem para a resistência, risco se o regime decifrar) · Descartar (item não vai ao ar; quem enviou pode voltar).

### Validação (estilo Papers Please)
- **Caderno do apresentador** = livro de regras que cresce a cada noite: palavras proibidas da noite, bairros evacuados/toque de recolher, informantes conhecidos, presos e desaparecidos, remetentes que já mentiram, códigos da resistência.
- **O que conferir:** celular (número, data, foto anexa, histórico do remetente); carta (carimbo, lacre, letra, endereço; envelope reselado = o governo leu antes); propaganda (contradiz fato verificado → pode ironizar); ligação (nome, bairro, voz).
- **Marcar e cruzar:** o jogador liga um trecho do item a um trecho do caderno ("Rua Aurora" ↔ "evacuada ontem"). Contradição encontrada marca o item como suspeito. Não encontrar não garante que seja verdadeiro. Erro não é punido na hora: o item falso vai ao ar e a consequência chega de manhã.

### Apresentação ao vivo (mecânica central: teleprompter)
- O roteiro do bloco sobe na tela enquanto o jogador segura o botão do microfone. Soltar = ar morto, audiência cai por segundo.
- Palavras proibidas aparecem no roteiro sem destaque; clicar troca por sinônimo aprovado. Deixar passar = infração anotada pelo regime.
- 2–3 momentos de improviso por bloco: o roteiro para e o jogador escolhe a próxima frase com tempo contado. Aqui o enquadramento vira fala.
- Ligações com delay de 7 s: a transcrição aparece 7 s antes do público ouvir; botão de corte.
- Trilha entre blocos: escolher a música é mandar sinal (códigos no caderno).
- **Só a audiência reage ao vivo** (ponteiro de ouvintes). O regime não tem medidor; só sinais vagos (luz de carro na janela, telefone mudo). Consequência real chega de manhã.
- Eventos: queda de energia (gerador, cortar um bloco), interferência (girar dial sem parar de falar), batida na porta, ouvinte em perigo ao vivo.

### Medidores
Confiança da audiência · Atenção do regime · Temperatura das ruas (calmo ↔ explosivo) · Recursos da rádio. O design atual tem Poder (visível), Integridade (escondida) e Inconsistência. **Proponha num ADR como reconciliar os dois modelos** (quais medidores ficam, quais são derivados, quais são escondidos) e me pergunte antes de decidir.

### Fase de dia
Transmissor (peças, combustível), sinal (alcance maior = triangulação mais fácil; trocar frequência ou esconderijo), equipe (quem sai buscar peças, quem pode ser preso), dinheiro (patrocinador suspeito cobra depois).

### Celular → cartas
O jogo começa com celular; no meio da campanha o governo corta a internet e a interface passa a ser cartas e telefone fixo. O telefone fixo existe nas duas fases.

### Personagens recorrentes
Dona Célia (ouvinte idosa, termômetro do bairro) · O Técnico (único amigo, pode ser preso, fugir ou trair) · O Contato (funcionário do governo, proteção ou caçada?) · A Líder da Oposição (amada, mas surge prova de que não é limpa) · O Âncora da TV estatal (quem você vira se ceder).

### Finais
Destino do país (reforma, cinza/agridoce, repressão total, colapso/guerra civil) combinado com destino pessoal (preso/exilado, cooptado pela rádio estatal, demagogo que toma o lugar do regime, lenda que some enquanto a frequência continua). Reaproveite e reconcilie os 7 finais já descritos em `GAME_DESIGN.md`.

### Tela
Uma tela só, visão em primeira pessoa da mesa do estúdio:
- topo: janela para a rua (única pista do regime) · ponteiro de ouvintes
- centro: microfone + teleprompter (elemento principal)
- esquerda: celular · direita: pilha de cartas e caderno
- base: os 4 blocos do programa (bloco de cota com moldura tracejada)
Celular, cartas e caderno abrem em close legível.

## 2. Pixel art feita por você

Você mesmo vai produzir a pixel art, de forma reproduzível:
- Crie um gerador em `tools/pixelart/` (prefira um script GDScript rodado com `godot-4 --headless -s ...` usando a API `Image` e `save_png`, para não adicionar dependências; se escolher outra ferramenta, justifique em ADR). Os sprites são definidos como dados (mapas de pixels ou primitivas) com uma paleta fixa em arquivo próprio. Gerar de novo sempre produz os mesmos PNGs.
- PNGs gerados vão para `assets/sprites/` e são versionados. Filtro de textura nearest.
- Paleta limitada: estúdio em âmbar quente (lâmpada, válvulas) contra o azul frio da rua. A cor deve poder se esvair conforme o cerco aperta (paleta alternativa ou shader: decida em ADR).
- Resolução base (ex.: 320×180 ou 480×270) com escala inteira. Isso muda `project.godot` (hoje `stretch/mode="canvas_items"`, `aspect="expand"`): registre em ADR.
- Documentos em close (cartas, celular, caderno) são híbridos: moldura em pixel art, texto em Courier Prime em alta resolução para ficar legível. Registre em ADR.
- Continue sem `_draw()`: use `TextureRect`, `NinePatchRect` e afins, editáveis no editor.
- Rostos quase nunca aparecem: pessoas existem por voz, letra e foto no envelope.
- Crie um teste GUT de manifesto de assets (todo sprite referenciado existe; dimensões esperadas; cores dentro da paleta).

## 3. Arquitetura (proposta a validar no SPEC)

Mantenha as 3 camadas: Dados (Resources) → Lógica pura (RefCounted, testável sem cena) → Apresentação (cenas que só escutam sinais do autoload). Módulos que imagino, para você refinar:
- **Dados:** `BroadcastItem` (tipo, remetente, texto, "fatos" verificáveis, efeitos por enquadramento), `NightDefinition` (itens da noite, cota, regras novas do caderno, roteiros), `NotebookEntry`, `Script/ScriptLine` do teleprompter (palavras proibidas, pontos de improviso).
- **Lógica pura:** `Meters`, `Notebook`, `Validator` (cruza fatos do item com o caderno e devolve contradições), `ProgramRundown` (4 blocos, cota, efeitos de ordem), `ConsequenceQueue` (efeitos agendados para a manhã seguinte), `LiveBroadcast` (máquina de estados do ao vivo: progresso do teleprompter, ar morto, troca de palavras, improviso com timer, delay e corte de ligação), `DayPhase`, `EndingResolver` v2.
- **Testabilidade:** tempo injetado (`tick(delta)`), nada de `Time`/timers dentro da lógica pura; RNG com seed injetada.
- **Migração:** `Choice`, `RadioEvent` e os 3 eventos atuais foram feitos para o loop antigo. Decida em ADR se migram, convivem ou são removidos. Se testes antigos forem removidos, que seja uma decisão explícita no ADR, nunca um teste apagado em silêncio.
- **Conteúdo da noite 1** como fatia vertical: 2 mensagens de celular, 1 carta, 1 propaganda, com pelo menos 1 fraude detectável pelo caderno.

## 4. Processo que vale para todas as sessões

- **SDD:** `docs/SPEC.md` é a fonte de verdade técnica. Toda mecânica nova entra primeiro no SPEC, com critérios de aceite, antes de código.
- **TDD:** para toda lógica em `scripts/core/`: teste GUT falhando → código mínimo → refatorar. Um marco só está concluído com a suíte inteira verde headless (mostre a saída). Lembre do `godot-4 --headless --import` após criar `class_name` novo.
- **ADRs:** em `docs/adr/NNNN-titulo-curto.md` (numeração sequencial), formato curto: Status (proposto/aceito/substituído), Contexto, Decisão, Alternativas consideradas, Consequências. Crie um ADR sempre que tomar uma decisão de arquitetura, ferramenta, formato de dados, escopo ou quando reverter uma anterior. Mantenha `docs/adr/README.md` como índice.
- **Documentação do fluxo:** mantenha `docs/ROADMAP.md` (marcos, status de cada um, o que vem depois) e atualize `GAME_DESIGN.md`/`SPEC.md` ao fim de cada marco quando algo mudar.
- **CLAUDE.md:** atualize quando uma convenção, comando, pasta ou regra mudar (ex.: pipeline de pixel art, pasta de ADRs, novo comando de teste). Mantenha-o curto; detalhes vão para `docs/`.
- **Commits:** pequenos e revisáveis, um assunto por commit, mensagens em português.

## 5. Entregáveis DESTA sessão (e depois pare)

1. Saída da suíte GUT atual (linha de base).
2. `docs/GAME_DESIGN.md` reescrito com a visão da v1 (seção 1), preservando o que já existe e fizer sentido.
3. `docs/SPEC.md` v1: modelo de dados, módulos de lógica com assinaturas, sinais do autoload, pipeline de pixel art, e uma tabela de marcos novos (a partir do M4) com critérios de aceite testáveis. Sugestão de ordem, que você pode ajustar justificando:
   - M4 Casa em ordem (branch, `.gitignore`, `.godot/`, pasta de ADRs, ROADMAP)
   - M5 Dados v1 + Caderno + Validator (TDD)
   - M6 Programa: 4 blocos, cota, enquadramentos, ordem + ConsequenceQueue
   - M7 Pipeline de pixel art + cena da mesa + triagem e escalação (arrastar)
   - M8 Ao vivo: teleprompter, microfone/ar morto, palavras proibidas, improviso, ligação com delay
   - M9 Manhã: manchetes e cartas de consequência → **fatia vertical: noite 1 jogável de ponta a ponta**
   - M10 Fase de dia · M11 Finais país × pessoal · M12 Conteúdo das noites e corte da internet · M13 Som e polimento
4. ADRs iniciais (pelo menos): branch principal e `.gitignore`; reconciliação dos medidores; migração de `Choice`/`RadioEvent`; pipeline de pixel art e resolução/escala; texto híbrido nos documentos; tempo injetado na lógica ao vivo.
5. `docs/ROADMAP.md` e `CLAUDE.md` atualizados.
6. Uma lista das perguntas que precisam da minha decisão (branch principal, medidores, número de noites da campanha, etc.).

Não comece o M4 até eu aprovar o plano.