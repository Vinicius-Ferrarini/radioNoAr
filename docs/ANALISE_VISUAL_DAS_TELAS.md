# Análise visual das telas — interface do estúdio

> Estado: direção visual e integração executadas em 2026-09-30.
> Celular, pauta, briefing, caderno, manhã e console ao vivo usam o kit.
> A cidade visual continua dependente da fase 3 do ADR 0013.

## Diagnóstico das capturas atuais

As sete capturas de `tools/qa/capture_radio.gd` mostram que o cenário já
tem bons elementos — janela, madeira, telefone, caderno, microfone e luz
vermelha — mas a interface cobre justamente aquilo que dá personalidade
ao jogo.

1. **Os overlays tomam a tela.** Briefing, caderno e manhã viram folhas ou
   painéis quase de ponta a ponta. A mesa some e cada etapa parece uma
   página de texto separada.
2. **Quase toda ação usa o mesmo retângulo vermelho.** Preparar, entrar no
   ar, ligar microfone, música, anúncio e corte recebem peso parecido.
   Falta distinguir ação comum, ação selecionada e perigo.
3. **O programa é representado por quatro caixas numeradas.** As caixas
   explicam a regra, mas não parecem uma pauta de rádio nem mostram de
   relance pessoa, origem ou compromisso editorial.
4. **O console ao vivo é uma pilha de texto.** Teleprompter, ligação,
   estados da linha e comandos disputam atenção. As lâmpadas são palavras
   precedidas por círculos tipográficos; não parecem lâmpadas físicas.
5. **A informação tem pouca profundidade.** Fundo, documento e botão
   compartilham bordas e valores próximos. O jogador precisa ler para
   descobrir o que é cenário, objeto, status e ação.
6. **A ação principal muda de lugar.** O botão `ENTRAR NO AR` fica afastado
   da sequência dos quatro blocos. No console, o corte aparece dentro da
   ligação, enquanto microfone, música e anúncio ficam abaixo.
7. **A manhã é outro mural de texto.** A consequência chega como relatório,
   não como mudança visível no mundo. A solução completa depende da fase
   da cidade do ADR 0013, mas a hierarquia do jornal já pode melhorar.

## Linguagem visual implementada

A interface passa a comunicar o tipo de interação pelo material:

| Material | Uso | Cor dominante |
|---|---|---|
| vidro do celular | conversa, histórico e respostas | azul frio |
| papel e pasta | apuração, briefing, caderno e manhã | creme e cinza |
| metal do console | transmissão, fila, teclas e temporizadores | madeira escura e âmbar |
| luz de emergência | no ar, corte e imposição oficial | vermelho |

O vermelho deixa de ser a cor padrão de botão. Ele fica reservado para
`NO AR`, `CORTAR`, palavra proibida já alcançada e pauta oficial. Âmbar
indica a ação principal segura; azul indica navegação e conversa; papel
indica algo que pode ser lido ou conferido.

O estúdio deve permanecer visível em todas as fases. Um close pode ocupar
até 40–45% da largura quando a leitura permitir. Documentos maiores entram
como pasta sobre a mesa, preservando uma faixa de cenário e os objetos que
servem de navegação.

## Proposta por tela

### Preparação e briefing

- Trocar o modal central por uma pasta de turno aberta sobre a mesa.
- Mostrar data, gancho da noite e recursos em três linhas curtas.
- Usar um único comando âmbar para começar; dicas longas aparecem só na
  primeira noite ou em ajuda contextual.
- Depois de começar, a faixa de pauta permanece visível e mostra quatro
  cartuchos, não quatro números vazios.

### Conversas no celular

- O celular abre à esquerda e ocupa aproximadamente 39% da tela; janela,
  luz e mesa continuam animadas à direita.
- Cabeçalho compacto com avatar, nome, horário e não lidas.
- Cada resposta recebe um sinal de intenção sem revelar moralidade:
  azul para pedir/conferir, âmbar para negociar e vermelho para confronto
  ou risco. O texto continua sendo a escolha real.
- Resposta bloqueada por apuração aparece como encaixe vazio ou cadeado
  discreto, com o trecho de evidência necessário. Ela não deve simplesmente
  desaparecer, porque isso esconde do jogador que há algo a descobrir.

### Pauta do programa

- Cada item vira um cartucho físico com faixa de remetente, duas linhas de
  resumo e selo de estado.
- A pauta oficial tem lombada vermelha. Os demais cartuchos usam azul.
- O encaixe mostra ordem e duração por posição. A seleção recebe contorno
  âmbar; espaço vazio recebe somente o trilho, sem caixa vermelha.
- `ENTRAR NO AR` fica acoplado ao fim da sequência, como próxima etapa.

### Caderno e apuração

- Usar a pasta de papel para separar este close do celular e do console.
- Converter fatos em recortes curtos, cada um com origem/data e área
  clicável inteira. A frase cruzada fica presa na margem como tira vermelha.
- Mostrar a relação com um fio ou carimbo entre dois trechos, sem depender
  apenas de `CONTRADIÇÃO`, `CONFERE` ou `SEM RELAÇÃO` em texto.

### Ao vivo

- Reduzir o teleprompter a uma janela de três faixas: linha anterior
  apagada, linha atual clara e próxima linha escura. A varredura permanece.
- Colocar a ligação em um chassi metálico próprio, com telefone à esquerda,
  transcrição no centro e três lâmpadas físicas à direita.
- Deixar `CORTAR` imediatamente abaixo das lâmpadas, perto do estado que ele
  altera. Microfone, música e anúncio viram teclas físicas menores.
- Manter os quatro cartuchos na base, para o jogador sempre saber onde está
  no programa. O cartucho atual recebe âmbar; o transmitido escurece.
- Usar texto para nome e conteúdo, ícone/cor para estado. Nunca exigir que
  o jogador leia uma legenda para saber se a linha está livre ou no ar.

### Manhã

- Manter papel, mas quebrar a página em manchete, repercussão local e visita
  recebida, cada uma com marca visual própria.
- Preservar o estúdio ao redor e colocar a ação de continuar na margem
  inferior da folha.
- Quando a cidade do ADR 0013 existir, a matéria aponta para o distrito
  alterado e a mudança aparece no mapa. Até lá, pequenos selos de bairro
  evitam que toda consequência pareça o mesmo parágrafo.

## Assets gerados

Todos seguem o pipeline determinístico, a paleta vigente e filtro nearest.

| Asset | Finalidade |
|---|---|
| `console_call_frame` | chassi nine-patch da ligação |
| `console_lamp_free` | estado livre em azul |
| `console_lamp_preview` | estado prévia em âmbar |
| `console_lamp_on_air` | estado no ar em vermelho |
| `console_key` | tecla física nine-patch |
| `program_cart` | cartucho comum de pauta |
| `program_cart_quota` | referência do cartucho oficial; a cena usa o caminho compatível `block_slot_quota`, redesenhado no mesmo formato |
| `phone_glass_panel` | painel nine-patch de conversa |
| `paper_folder_panel` | pasta nine-patch de apuração |
| `ui_planning_concept` | composição de referência da preparação |
| `ui_live_console_concept` | composição de referência do ao vivo |

As imagens de conceito continuam como referência de proporção e hierarquia. Não devem
ser colocadas como fundo chapado na cena final; os elementos interativos
devem continuar sendo nós editáveis no Godot.

## Integração executada

1. **Tema e estados:** concluído. Botão comum é neutro; âmbar é ação
   principal; azul é conversa; vermelho é perigo ou imposição.
2. **Preparação e celular:** concluído. O briefing virou pasta lateral e o
   celular ocupa 118×149, mantendo a maior parte do estúdio visível.
3. **Pauta e apuração:** concluído. Slots viraram cartuchos; caderno e manhã
   usam pasta de papel; a cota tem lombada vermelha.
4. **Console ao vivo:** concluído. Teleprompter foi compactado, a ligação
   ganhou chassi e lâmpadas físicas, e a pauta permanece visível no ar.
5. **Manhã e polimento:** parcialmente concluído. Material, hierarquia e
   ação principal foram integrados; cartões por distrito dependem do mapa
   da cidade ainda proposto no ADR 0013.

A integração terminou com a suíte GUT, as sete capturas do roteiro de QA e
duas capturas extras do celular. Não há motivo visual para trocar a resolução
320×180: a hierarquia cabe na base aceita pelo ADR 0005.
