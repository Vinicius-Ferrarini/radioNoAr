# Rádio viva — plano de implementação

Autorizado pelo usuário em 2026-09-29: planejar e executar a revisão de
gameplay discutida na análise. Escopo: uma abertura completa de três
noites, antes de expandir para 21. Não inclui finais da campanha nem a
gestão completa da fase de dia.

## Experiência alvo

Começar como apresentador de bairro; aprender a operar o programa,
conhecer ouvintes e depois enfrentar a primeira pressão editorial.
Investigar deve mudar o que é possível afirmar. Reações acontecem no ar;
as repercussões chegam de manhã e mudam a próxima noite.

## Sequência de execução

1. Registrar ADR 0011 e contrato no SPEC antes do código.
2. Testar investigação: enquadramentos com evidência exigem cruzamento
   real, não basta marcar suspeita. Rótulos descrevem falas concretas.
3. Testar ligação agendada, delay, corte, intervalo finito e resultado
   persistido. Uma reserva de intervalo por noite: música ou anúncio.
4. Integrar controles à mesa: microfone alternável, prévia e corte,
   caderno acessível ao vivo, retorno imediato e avanço explícito à manhã.
5. Escrever três noites curtas e ramificadas, preservando a antiga noite
   em `data/nights/` como cenário de regressão. A abertura usa `data/pilot/`.
6. Gerar telefone de estúdio, toca-discos, retratos/objetos narrativos e
   sons originais por scripts determinísticos; integrar os assets.
7. Rodar importação, suíte GUT, percursos completos dos dois caminhos e
   capturas renderizadas da interface. Corrigir problemas encontrados.
8. Atualizar estado e roadmap com evidências e limitações reais.

## Três noites

- **1 — A nossa frequência:** aniversário da Célia, oficina, futebol e
  achados do bairro. Uma ligação bem-humorada ensina a prévia. Música
  atende o pedido; anúncio ajuda a oficina e paga a rádio.
- **2 — A ponte:** boletim oficial contradiz informação verificável.
  Rui, motorista conhecido, liga sobre o bloqueio. Cortar ou transmitir
  seu relato gera respostas distintas. A apuração permite citar a fonte.
- **3 — Quem ficou ouvindo:** Rui volta conforme a decisão da noite 2;
  chegam um favor oficial e um pedido da comunidade. A decisão editorial
  muda a manhã final. Objetos na mesa recordam música, anúncio e ligação.

## Critérios de aceite

- Não há verdade automática: a evidência exigida é checada na lógica.
- Ligação chega pelo fluxo normal; corte antes do prazo impede o envio;
  após o prazo não reverte a transmissão; fim de bloco não perde ligação.
- Intervalo tem duração e estoque limitados; não produz ar morto; sua
  escolha deixa efeito distinto e observável no dia seguinte.
- Microfone pode ser alternado sem segurar tecla. A prévia informa prazo
  e resultado. Textos críticos não dependem de tooltip para leitura.
- As três noites são concluíveis sem abrir console; há reinício ao fim.
- Decisões da noite 2 alteram conteúdo e reação da noite 3; a manhã
  explica o efeito sem expor medidores ocultos.
- Assets têm arquivos fonte e saída; manifesto e suíte passam.
- Testes verificam regras e integração; diversão fica sujeita a playtest
  humano, com atenção a clareza, ritmo e vontade de continuar.

## Validação humana sugerida

Observar jogadores sem explicar os controles. Registrar onde travam,
qual acontecimento lembram e se conseguem explicar a decisão do corte.
Pedir a um espectador que descreva o risco antes de a ligação ir ao ar.
Só expandir o volume da campanha após avaliar essas respostas.

## Resultado da execução

Etapas 1–8 implementadas. Validação final: 282/282 testes, 83.878 asserts
(o tempo varia com a máquina: de 8 s a 14 s nas execuções registradas).
A suíte original de 265 testes foi preservada, com o catálogo antigo
explicitado e a expectativa de ferramentas acessíveis ao vivo atualizada
no teste de UI. Novos testes cobrem regras e dois percursos.

Foram gerados 8 sprites novos e 6 WAVs sintetizados. A verificação
renderizada percorreu triagem, apuração, ligação, intervalo, manhã e
abertura das noites seguintes. Detectou e corrigiu texto sobreposto no
briefing, contraste do jornal e desaparecimento precoce da reação ao
trocar de bloco. Capturas em `.godot/radio-qa/` (geradas, não versionadas).

### Primeiro playtest humano (2026-09-29)

O dono jogou a noite 1 de ponta a ponta. Dois achados:

1. **Não havia como entrar no ar.** Bloco com item e sem enquadramento
   ficava idêntico a um pronto, e o botão AO AR ficava desabilitado e
   mudo. Corrigido, e criado um botão ENTRAR NO AR dedicado que nunca
   desabilita e abre o que falta resolver.
2. **"Ainda parece chato e monótono, com somente texto e escolhas."**
   Endereçado pela passada de atmosfera do ADR 0012: leito de som
   contínuo, ar morto audível, mesa em movimento.

Segue pendente o que nenhum dos dois resolve: o ritmo da leitura em si e
a diversão. Próximo playtest deve olhar os blocos de ~16 s em que o
jogador só segura o microfone.

Limites: áudio ainda não tem dublagem e a captura usa saída Dummy.
O alvo entregue é a abertura de três noites;
não foram implementados a campanha de 21 noites nem seus finais.
