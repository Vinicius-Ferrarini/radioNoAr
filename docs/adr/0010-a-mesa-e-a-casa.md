# 0010 — A mesa é a casa: closes diegéticos no lugar do painel com abas

- **Status:** aceito (decisão do designer em 2026-09-29, olhando o jogo rodando)
- **Data:** 2026-09-29

## Contexto

O M8 entregou a triagem funcionando: dá para ler os itens, cruzar com o
caderno, marcar suspeita, arrastar para os blocos e enquadrar. Todos os
testes passam. E o jogo ficou ruim de olhar e sem graça de jogar.

O que a tela mostrava: um `Panel` retangular cobrindo a mesa inteira, com
três abas e seis botões idênticos em vermelho. Carta, mensagem de celular
e comunicado oficial com exatamente a mesma aparência. Texto cortado no
meio ("Uma carta pedind"). Nenhum remetente com nome ou cara. Sem tela de
título: o jogo começava no meio.

O `GAME_DESIGN.md` §12 já descrevia a tela certa — "esquerda: celular ·
direita: pilha de cartas e caderno · Celular, cartas e caderno abrem em
close legível" — e a implementação não seguiu. Não foi falta de
especificação: foi eu construir a interface que era fácil de montar com
`Control` em vez da que o documento pedia.

O diagnóstico que importa: **a triagem é sobre reconhecer de onde a coisa
veio**, e uma interface que pinta todas as origens do mesmo jeito apaga a
mecânica central do jogo.

## Decisão

A mesa do estúdio é a tela inicial e nunca some. Os objetos em cima dela
é que abrem.

1. **Sem `Panel` genérico.** Toda superfície de interface é um objeto do
   mundo: corpo do celular, folha de papel, capa do caderno, painel de
   metal do estúdio. Um retângulo liso com borda só aparece se for um
   retângulo liso com borda dentro da ficção.
2. **Três closes, três materiais**, cada um com tipografia e conferíveis
   próprios:

   | | Celular | Carta | Oficial |
   |---|---|---|---|
   | Superfície | tela azul fria, bolhas | papel creme, margem larga | papel acinzentado |
   | Voz | informal, com hora | corrido, com assinatura | caixa alta, nº de protocolo |
   | O que se confere | número, data, foto anexa, histórico | carimbo, lacre, letra | carimbo do Ministério |

3. **Remetente vira personagem.** `BroadcastItem.sender_id` deixa de ser
   string solta e passa a apontar para um `Sender` (nome, avatar, forma
   de tratamento). Dona Célia, O Técnico, O Contato, a Líder e o Âncora
   saem do documento de design e entram no jogo.
4. **Avatares granulados e ambíguos** (16×16, escuros, às vezes um ombro
   ou um cachorro em vez de um rosto). Isso não contradiz a regra de tom
   "rostos quase nunca aparecem" — é a realização dela: o design já dizia
   que as pessoas existem por voz, letra e *uma foto ruim*. Um avatar de
   aplicativo de mensagem é exatamente uma foto ruim.
5. **Luz.** `CanvasModulate` âmbar contra o azul da janela, para o
   estúdio ser um lugar e não um fundo. É também o gancho já previsto no
   ADR 0008.
6. **Tela de título e opções** antes do jogo (sem salvar por ora: a
   campanha de 21 noites ainda não existe para ser salva).

Isso entra como dois marcos **antes** do ao vivo: **M8B** (remetentes,
closes, luz) e **M8C** (menu, opções, transições). O M9 é construído em
cima dessa linguagem visual, em vez de ser construído sobre caixas e
refeito depois.

## Alternativas consideradas

- **Terminar o loop primeiro (M9 e M10) e só então cuidar do visual.**
  Rejeitado: o ao vivo é a tela mais complexa do jogo. Construí-la sobre
  a linguagem errada significaria refazê-la inteira depois — e a
  desmotivação de jogar algo feio por mais dois marcos é um custo real,
  não estético.
- **Melhorar o painel de abas** (ícones por canal, cores por tipo).
  Rejeitado: trata o sintoma. O painel continuaria cobrindo a mesa, e os
  objetos do design continuariam sem existir.
- **Retratos legíveis dos personagens.** Rejeitado pelo designer: cria
  vínculo mais rápido, mas quebra a regra de tom do documento, que é uma
  das coisas que dão identidade ao jogo.
- **Adiar o menu para o polimento (M14).** Rejeitado: começar no meio da
  noite 1, sem título, é parte do que faz o jogo não parecer um jogo.

## Consequências

- O `WorkPanel` do M8 é removido, e com ele as abas ITEM/CADERNO/BLOCO.
  Os testes de interface do M8 são reescritos, não apagados — a garantia
  que eles davam (cruzar trecho com caderno funciona pela interface)
  continua valendo, mudando só por onde o jogador faz isso.
- `Sender` é dado novo: o teste de sanidade de conteúdo passa a exigir
  que todo `sender_id` citado por um item exista em `data/senders/`.
- O catálogo de sprites cresce bastante (avatares, molduras, bolhas,
  carimbos). O pipeline do ADR 0004 aguenta: são dados em texto, e o
  teste de manifesto continua cobrando paleta e determinismo.
- A regra "UI 100% em nós Control, nunca `_draw()`" continua valendo e
  fica mais fácil de cumprir: molduras de papel e bolhas são
  `NinePatchRect`.
