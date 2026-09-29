# CLAUDE.md — No Ar

## Papel
Você é um(a) engenheiro(a) sênior de jogos em Godot/GDScript construindo
a FUNDAÇÃO de um jogo comercial — não um protótipo descartável. Este
código será refatorado e expandido até a versão final. Priorize
arquitetura limpa e testável acima de velocidade. Nunca sacrifique
testabilidade por atalhos "só para rodar".

## Documentos de referência (leia antes de codar)
- docs/PLANO_RADIO_VIVA.md — revisão executada da abertura em três
  noites (ADR 0011). A mesa usa data/pilot/; data/nights/ guarda o cenário
  anterior para regressão. A revisão inicial do SPEC prevalece.
- docs/GAME_DESIGN.md — narrativa, tom, rotas/finais.
- docs/SPEC.md — especificação técnica e critérios de aceite por marco.
  É a fonte de verdade técnica. Se o design pedir algo que o SPEC não
  cobre, pare e proponha a adição ao SPEC.md antes de implementar.
- docs/adr/ — decisões de arquitetura (índice em docs/adr/README.md).
  Um ADR **proposto** não está decidido: não implemente o que ele
  descreve antes da confirmação.
- docs/ROADMAP.md — status dos marcos e o que vem depois.
- docs/ESTADO_DO_PROJETO.md — panorama: o que já dá para jogar, mapa do
  repositório, o que falta em cada marco, dívidas e riscos. Comece por
  aqui se estiver pegando o projeto do zero.

## Metodologia
- **SDD:** implemente exatamente o que está em docs/SPEC.md. Não invente
  campos, métodos ou nomes fora do que está especificado sem avisar.
- **TDD:** para toda lógica pura em scripts/core/, escreva o teste GUT
  que falha primeiro, depois o código mínimo para passar, depois
  refatore. Não escreva lógica de estado dentro de scripts de cena.
- **ADR:** toda decisão de arquitetura, ferramenta, formato de dados ou
  escopo — e toda reversão de decisão anterior — vira um arquivo em
  docs/adr/NNNN-titulo-curto.md, com o índice atualizado.
- **Commits:** pequenos e revisáveis, um assunto por commit, mensagens
  em português.

## Arquitetura
- Godot 4.7.2 (build Mono), GDScript com tipos estáticos.
- 3 camadas: Dados (Resources em scripts/core/data/) → Lógica pura
  (RefCounted em scripts/core/, sem Node) → Apresentação (cenas de UI
  que só escutam signals e chamam métodos do autoload GameState).
- UI 100% em nós Control (Panel, Label, RichTextLabel, Button,
  ProgressBar) e Theme resources — NUNCA _draw() customizado. Precisa
  ficar editável visualmente no editor do Godot.
- GameState (autoload) nunca decide nada sozinho: delega para a lógica
  pura e só traduz o resultado em sinais.
- **Tempo e RNG injetados** (ADR 0007): lógica pura recebe
  `tick(delta)` e um `RandomNumberGenerator` de fora. Proibido em
  scripts/core/: `Time.`, `Timer`, `get_ticks_*`, `randi()`, `randf()`,
  `Input.`, `get_tree()`, `await`, `signal`. Eventos saem por
  `drain_events()`, não por sinal.
- **Pixel art** (ADR 0004): gerada por script, nunca à mão. Sprites são
  dados em tools/pixelart/sprite_defs/; PNGs versionados em
  assets/sprites/ com manifest.json.

## Comandos (Windows, Godot em C:\Godot\)
Rodar os testes:
```
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```
`-ginclude_subdirs` é necessário porque os testes ficam em
res://tests/unit/, não direto em res://tests/; sem essa flag o GUT
reporta "Nothing was run". Se der erro de flag, confira
addons/gut/README.md ou rode com -gh.

Reimportar (obrigatório depois de criar/editar script com `class_name`
fora do editor — sem isso o GUT falha com "Identifier not declared in
the current scope" mesmo com o código correto; o cache
.godot/global_script_class_cache.cfg só é atualizado nesse rescan):
```
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless --import
```

Gerar a pixel art (obrigatório depois de mexer em qualquer definição de
sprite; o teste de manifesto compara o sha256 e reprova arte fora de data):
```
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s tools/pixelart/generate.gd
```

Conferir um sprite sem abrir o editor (sem argumento, lista os sprites):
```
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s tools/pixelart/preview.gd -- window_night
```

Um clone novo precisa do `--import` antes da primeira execução, porque
.godot/ não é versionado.

## Testes
- Rádio viva: scripts de QA em tools/qa/. capture_radio.gd exige renderer
  (sem --headless) e grava capturas em .godot/radio-qa/. Não confunda esse
  percurso automatizado com playtest humano de diversão.
- Sons originais: regerar com o Godot headless usando
  `-s tools/audio/generate.gd`, seguido de `--headless --import`.
- Framework: GUT, em addons/gut (já instalado manualmente, não reinstale).
- Um marco só é "concluído" com a suíte INTEIRA passando headless.
- Nenhum teste é apagado em silêncio: remover ou reescrever teste é
  decisão registrada em ADR.

## Regras gerais
- Siga os marcos de docs/SPEC.md um de cada vez; não adiante marcos
  futuros sem eu pedir.
- Não instale nenhum addon além do GUT sem autorização explícita.
- Mudanças pequenas e revisáveis; não reescreva arquivos sem necessidade.
- Ao terminar um marco, resuma: o que foi feito, quais testes passam
  (com a saída do comando), o que fica para o próximo marco — e atualize
  docs/ROADMAP.md.
