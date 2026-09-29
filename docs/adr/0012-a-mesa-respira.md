# 0012 — A mesa respira: leito de som e movimento

- Status: aceito — autorizado pelo playtest do dono em 2026-09-29.

## Contexto

Primeiro playtest humano da abertura, o que o `PLANO_RADIO_VIVA.md`
listava como pendente. Veredito de quem jogou a noite 1 inteira: o jogo
"ainda parece chato e monótono, com somente texto e escolhas", e falta
atmosfera.

O diagnóstico confere com o código. O jogo era silencioso: os 6 WAVs
existentes são todos disparos de um tiro (chave, telefone, vinheta,
valsa, anúncio, corte), sem nenhum leito contínuo. A mesa era estática:
o letreiro AO AR recebia um valor fixo de opacidade, a lâmpada nunca
mudava, e a única coisa em movimento na tela era uma barra de progresso.
O ar morto — a pior coisa que pode acontecer no rádio — era comunicado
por uma frase no rodapé.

## Decisão

Criar uma camada de atmosfera **só de apresentação**. Nenhuma regra de
jogo muda; a lógica pura, o SPEC de conteúdo e os medidores ficam como
estão. A cena continua lendo o `GameState` e nada mais.

Dois leitos contínuos em loop, mixados por estado da mesa:
`room_tone` (zumbido do estúdio) sempre presente, e `radio_static`
variando em dB — fora do ar −26, no ar −34, **ar morto −11**, intervalo
−42. O silêncio passa a ter som, e o ar morto dói no ouvido antes de
aparecer escrito.

A mesa se move: o letreiro pulsa e acompanha o estado **real** da
transmissão (`LiveBroadcast.State`), não a posição da chave — em ar morto
ele apaga junto com a voz; a lâmpada oscila; o telefone treme e pisca
enquanto a ligação espera no atraso de sete segundos. Tudo por
`modulate` e `position`, sem `_draw` (ADR 0004 e CLAUDE.md).

`_breathe(delta)` é o dono único das propriedades animadas: as
atribuições avulsas do letreiro em `_on_phase_changed` e `_refresh_live`
foram removidas, porque duas mãos no mesmo valor por frame é bug à
espera.

O gerador de áudio ganha `seamless`, que dispensa o envelope das pontas
para o loop não pulsar, e ruído reproduzível com semente fixa. O loop em
si vem de `edit/loop_mode=2` no `.import` — verificado empiricamente:
resulta em `LOOP_FORWARD`. Um teste guarda isso, porque leito sem loop
toca uma vez e emudece a mesa em silêncio.

## Alternativas

- Continuar comunicando estado só por texto: é exatamente o problema
  relatado.
- Dublagem agora: caro, e não é necessário para testar atmosfera. As
  falas seguem legendadas.
- Animar por `_draw` ou shader: proibido pela arquitetura; `modulate` e
  `position` bastam.
- Trocar a mecânica por mais ação: é outra decisão, de escopo maior. Esta
  passada trata do que o playtest apontou — atmosfera — sem mexer em
  regra.

## Consequências

O estúdio deixa de ser mudo e parado. Não há dublagem: os leitos são
sintetizados e provisórios. A monotonia da **leitura** em si — blocos de
~16 s em que o jogador só segura o microfone — não é resolvida aqui e
continua a maior suspeita para o próximo playtest, junto do ritmo.
