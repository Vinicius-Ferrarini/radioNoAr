# No Ar — Documento de Design (v1)

> Status: visão da v1. Substitui o documento da v0 (loop de 1 notícia e 3
> botões por noite), preservando premissa, tom e o catálogo de finais.
> Fonte de verdade técnica: `docs/SPEC.md`. Decisões de arquitetura:
> `docs/adr/`.

## Revisão da abertura — Rádio viva

Decisão autorizada em 2026-09-29 (ADR 0011). Esta revisão prevalece nas
três noites iniciais sobre a descrição anterior abaixo. O protagonista
começa como apresentador de uma rádio de bairro, com música, classificados,
aniversários e um patrocinador. Tornar-se a última rádio livre é uma
possibilidade da escalada, não sua identidade inicial.

A reação ocorre no ar; o alcance da consequência aparece depois.
Investigar revela falas apoiadas em evidências. Os botões descrevem o
que será dito, sem um botão universal que saiba a verdade pelo jogador.
O microfone é alternável. Uma reserva de seis segundos por noite pode
ser usada para música ou anúncio, segurando o programa e a ligação em
prévia. Música cria vínculo; anúncio remunera a rádio e traz cobrança.

A abertura executável tem três noites: rotina, ponte interditada e
repercussão. Ligações, bilhetes e objetos na mesa mostram quem está
ouvindo e quem ficou devendo um favor. Não há barra de facção na mesa.
Plano, critérios e limites: `PLANO_RADIO_VIVA.md`.

## 1. Premissa (visão anterior da campanha completa)

Um país fictício com um governo apertando o cerco (censura, "medidas de
emergência") enquanto as ruas pedem eleições livres. O jogador é o último
apresentador de uma rádio livre. Sem partidos, siglas ou políticos reais
— o alvo é a relação entre poder e informação, não uma disputa atual.

Uma contagem regressiva de **21 noites** até o referendo dá o prazo da
campanha: três semanas de calendário, espaço suficiente para a cota de
propaganda subir de 1 para 3 e para o corte da internet acontecer no
meio do caminho.

### Regras de tom (valem para todo conteúdo)

- **A consequência nunca aparece na hora.** O que o jogador faz no ar
  volta como manchete, carta ou bilhete na manhã seguinte — às vezes de
  forma ambígua, às vezes sem nunca ficar claro.
- **Nenhuma escolha é rotulada como "a certa".** A verdade pode ser
  armadilha; acalmar pode salvar vidas; inflamar dá poder real e pode
  transformar o jogador no próximo demagogo.
- **Rostos quase nunca aparecem.** As pessoas existem por voz, letra,
  carimbo e uma foto ruim dentro de um envelope.
- **O regime não tem medidor.** Só sinais vagos: um farol de carro parado
  na rua, o telefone que fica mudo, um envelope que chegou reselado.

## 2. Loop de uma noite

1. **Noite — triagem.** Chegam mais itens do que cabem no programa: pelo
   celular, por cartas e como propaganda oficial. O jogador lê, confere e
   marca cada um.
2. **Escalação.** Arrasta itens para os 4 blocos do programa. A ordem
   importa: propaganda logo depois de uma denúncia soa como ironia.
3. **Enquadramento.** Escolhe como apresentar cada item escalado.
4. **No ar.** Apresenta ao vivo (seção 6).
5. **Manhã.** Manchetes, cartas e bilhetes mostram a consequência da
   noite anterior.
6. **Dia.** Gestão de transmissor, sinal, equipe e dinheiro. Depois, a
   próxima noite.

Fatia vertical de referência (noite 1): 2 mensagens de celular, 1 carta,
1 propaganda oficial, com pelo menos 1 fraude detectável pelo caderno.

## 3. Itens e quem os envia

| Tipo | O que pede | Ganho | Custo |
|---|---|---|---|
| Suborno | Dinheiro para falar ou calar algo | Combustível, peças, segurança | Credibilidade cai se descobrirem |
| Vendedor | Troca uma peça | Conserta o transmissor | Peça pode ser roubada ou grampeada |
| Vingança | Expor alguém no ar | Pode desmascarar um informante | Pode ser só briga de vizinho |
| Quer aparecer | Espaço no ar | Audiência, às vezes mensagem codificada | Ocupa um bloco |
| Pedido de ajuda | Dizer o nome de um desaparecido | Pressão pública protege | Pode condenar a pessoa |
| Propaganda oficial | Obrigatória (cota) | Evita atenção do regime | Um bloco a menos para o povo |

**Cota de propaganda:** número mínimo de blocos oficiais por programa,
crescendo com as noites (1 → 2 → 3). Recusar a cota atrai atenção do
regime em vez de ser bloqueado pela interface.

## 4. Enquadramentos

| Enquadramento | Leitura |
|---|---|
| Ler como chegou | Transfere a responsabilidade para quem enviou |
| Contar a verdade | O que foi apurado, inclusive quando não convém |
| Suavizar | Baixa a temperatura das ruas; pode custar confiança |
| Inflamar | Sobe a temperatura e a audiência; sobe a atenção do regime |
| Ironizar | Só para propaganda: recado para a resistência, risco alto se o regime decifrar |
| Descartar | Não vai ao ar; quem enviou pode voltar em outra noite |

## 5. Validação (estilo *Papers, Please*)

### Caderno do apresentador

Livro de regras que cresce a cada noite, com seções: palavras proibidas
da noite, bairros evacuados e em toque de recolher, informantes
conhecidos, presos e desaparecidos, remetentes que já mentiram, códigos
da resistência.

### O que se confere em cada canal

- **Celular:** número, data, foto anexa, histórico do remetente.
- **Carta:** carimbo, lacre, letra, endereço. Envelope reselado = o
  governo leu antes de você.
- **Propaganda:** contradiz um fato já verificado → abre o enquadramento
  "Ironizar".
- **Ligação:** nome, bairro, voz.

### Marcar e cruzar

O jogador liga um trecho do item a um trecho do caderno ("Rua Aurora" ↔
"evacuada ontem"). Encontrar contradição marca o item como suspeito. Não
encontrar nada **não** garante que o item seja verdadeiro. O erro não é
punido na hora: o item falso vai ao ar e a conta chega de manhã.

## 6. Apresentação ao vivo (mecânica central)

- **Teleprompter:** o roteiro do bloco sobe na tela enquanto o jogador
  segura o botão do microfone. Soltar = ar morto, e a audiência cai por
  segundo de silêncio.
- **Palavras proibidas:** aparecem no roteiro sem destaque; clicar troca
  por um sinônimo aprovado. Deixar passar = infração anotada pelo regime.
- **Improviso:** 2–3 momentos por bloco em que o roteiro para e o jogador
  escolhe a próxima frase com tempo contado. Aqui o enquadramento
  escolhido antes vira fala.
- **Ligações com delay de 7 s:** a transcrição aparece 7 s antes do
  público ouvir; existe um botão de corte.
- **Trilha entre blocos:** escolher a música é mandar sinal (os códigos
  estão no caderno).
- **Só a audiência reage ao vivo** (ponteiro de ouvintes). O regime não
  reage no ar; a consequência real chega de manhã.
- **Eventos ao vivo:** queda de energia (ligar o gerador ou cortar um
  bloco), interferência (girar o dial sem parar de falar), batida na
  porta, ouvinte em perigo ao vivo.

## 7. Medidores

Modelo decidido em `docs/adr/0002-reconciliacao-dos-medidores.md`
(Opção A):

| Medidor | Visibilidade | Papel |
|---|---|---|
| Confiança da audiência | visível (ponteiro de ouvintes) | quem ainda acredita em você |
| Temperatura das ruas | visível, qualitativa (calmo ↔ explosivo) | pressão popular |
| Atenção do regime | **escondida** | só sinais vagos na janela e no telefone |
| Alinhamento (Povo ↔ Governo) | visível | herdeiro do "Poder" da v0 |
| Integridade | **escondida** | herdada da v0: verdade/cautela ↔ interesse próprio |
| Inconsistência | **escondida**, contador | contradizer-se com o próprio passado |
| Recursos da rádio | visível | combustível, peças, dinheiro, equipe (fase de dia) |

## 8. Fase de dia

- **Transmissor:** peças e combustível; quebra reduz alcance.
- **Sinal:** mais alcance = triangulação mais fácil; trocar de frequência
  ou de esconderijo custa recursos.
- **Equipe:** quem sai para buscar peças, quem pode ser preso.
- **Dinheiro:** patrocinador suspeito cobra a conta depois.

## 9. Celular → cartas

A campanha começa com celular. No meio dela o governo corta a internet e
a interface passa a ser cartas e telefone fixo. O telefone fixo existe
nas duas fases — é a única ponte entre elas.

## 10. Personagens recorrentes

- **Dona Célia** — ouvinte idosa, termômetro do bairro.
- **O Técnico** — único amigo; pode ser preso, fugir ou trair.
- **O Contato** — funcionário do governo: proteção ou caçada?
- **A Líder da Oposição** — amada, até surgir prova de que não é limpa.
- **O Âncora da TV estatal** — quem você vira se ceder.

## 11. Finais

O final é um par: **destino do país × destino pessoal**.

**Destino do país:** Reforma · Cinza (agridoce) · Repressão total ·
Colapso (guerra civil / êxodo).

**Destino pessoal:** Preso ou exilado · Cooptado pela rádio estatal ·
Demagogo que toma o lugar do regime · Lenda que desaparece enquanto a
frequência continua.

### Reconciliação com os 7 finais da v0

| Final v0 | Onde vive na v1 |
|---|---|
| Caminho Cinza | país = Cinza, pessoal = lenda ou cooptado |
| A Reforma | país = Reforma, pessoal = lenda |
| O Mártir | país = Reforma, pessoal = preso/exilado |
| Repressão Total | país = Repressão, pessoal = cooptado ou preso |
| O Vendido | país = Repressão ou Cinza, pessoal = cooptado |
| O Maquiavel | país = qualquer, pessoal = demagogo |
| O Colapso | país = Colapso (gatilho: Inconsistência acima do limite) |

Nenhum final da v0 é descartado: cada um passa a ser uma célula da matriz
país × pessoal. Os textos que já existem em `scenes/ending.gd` ("cinza",
"reforma", "repressao") são o ponto de partida dos textos de país.

## 12. Tela

Uma tela só, em primeira pessoa, sentado à mesa do estúdio:

- **topo:** janela para a rua (única pista sobre o regime) · ponteiro de
  ouvintes
- **centro:** microfone + teleprompter (elemento principal)
- **esquerda:** celular · **direita:** pilha de cartas e o caderno
- **base:** os 4 blocos do programa; o bloco de cota tem moldura tracejada

Celular, cartas e caderno abrem em close legível por cima da mesa.

## 13. Estética

- Pixel art com paleta limitada, gerada por script versionado
  (`tools/pixelart/`, ver `docs/adr/0004-pipeline-de-pixel-art.md`).
- Estúdio em âmbar quente (lâmpada, válvulas) contra o azul frio da rua.
  Conforme o cerco aperta, a cor se esvai (ADR 0008).
- Documentos em close são híbridos: moldura em pixel art, texto em
  Courier Prime legível (ADR 0006).

## 14. Perguntas abertas (precisam de decisão do designer)

Decididas em 2026-09-29: campanha de 21 noites (§1); medidores no modelo
de seis eixos (§7, ADR 0002).

1. Em que noite a internet cai (§9). Proposta: noite 11, o meio exato da
   campanha — a resposta é necessária no M13, não antes.
2. Se o jogador pode perder antes do fim (rádio destruída, prisão,
   audiência zerada) ou se a campanha sempre chega ao referendo. Afeta o
   `EndingResolver` (M12) e a fase de dia (M11).
3. Se a cota de propaganda pode chegar a 4 (programa inteiro oficial) em
   alguma noite tardia, ou se o teto é 3.
