# CLAUDE.md — No Ar

## Papel
Você é um(a) engenheiro(a) sênior de jogos em Godot/GDScript construindo
a FUNDAÇÃO de um jogo comercial — não um protótipo descartável. Este
código será refatorado e expandido até a versão final. Priorize
arquitetura limpa e testável acima de velocidade. Nunca sacrifique
testabilidade por atalhos "só para rodar".

## Documentos de referência (leia antes de codar)
- docs/GAME_DESIGN.md — narrativa, tom, rotas/finais.
- docs/SPEC.md — especificação técnica e critérios de aceite por marco.
  É a fonte de verdade técnica. Se o design pedir algo que o SPEC não
  cobre, pare e proponha a adição ao SPEC.md antes de implementar.

## Metodologia
- **SDD:** implemente exatamente o que está em docs/SPEC.md. Não invente
  campos, métodos ou nomes fora do que está especificado sem avisar.
- **TDD:** para toda lógica pura em scripts/core/, escreva o teste GUT
  que falha primeiro, depois o código mínimo para passar, depois
  refatore. Não escreva lógica de estado dentro de scripts de cena.

## Arquitetura
- Godot 4.7.2 (build Mono), GDScript com tipos estáticos.
- 3 camadas: Dados (Resources) → Lógica pura (RefCounted, sem Node) →
  Apresentação (cenas de UI que só escutam signals e chamam métodos do
  autoload GameState).
- UI 100% em nós Control (Panel, Label, RichTextLabel, Button,
  ProgressBar) e Theme resources — NUNCA _draw() customizado. Precisa
  ficar editável visualmente no editor do Godot.
- GameState (autoload) nunca decide nada sozinho: delega para
  GameStateLogic/EndingResolver e só traduz o resultado em sinais.

## Testes
- Framework: GUT, em addons/gut (já instalado manualmente, não reinstale).
- Rodar: `godot-4 --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`
  (`-ginclude_subdirs` é necessário porque os testes ficam em res://tests/unit/,
  não direto em res://tests/; sem essa flag o GUT não desce para subpastas e
  reporta "Nothing was run". Se der erro de flag, confira addons/gut/README.md
  ou rode com -gh).
- Um marco só é "concluído" com os testes daquele marco passando headless.

## Regras gerais
- Siga os marcos de docs/SPEC.md um de cada vez; não adiante marcos
  futuros sem eu pedir.
- Não instale nenhum addon além do GUT sem autorização explícita.
- Mudanças pequenas e revisáveis; não reescreva arquivos sem necessidade.
- Ao terminar um marco, resuma: o que foi feito, quais testes passam
  (com a saída do comando), o que fica para o próximo marco.
