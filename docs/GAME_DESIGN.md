# No Ar — Documento de Design

## Premissa
Um país fictício com um governo apertando o cerco (censura, "medidas de
emergência") enquanto grupos nas ruas pedem eleições livres. O jogador é
a última voz de rádio que ainda escolhe o que dizer. Sem partidos, siglas
ou políticos reais — o alvo é poder e informação, não uma disputa atual.

## Loop
A cada noite: uma notícia/ligação chega. O jogador escolhe entre 3
respostas (1: verdade, 2: o que o público quer ouvir, 3: carisma/ataque,
que pode sair pela culatra). O efeito de uma escolha aparece só na noite
seguinte (consequência adiada).

## Medidores
- **Poder (visível, 0-100):** Povo (baixo) ↔ Governo (alto). Começa em 50.
- **Integridade (escondida, 0-100):** verdade/cautela (alto) ↔ interesse
  próprio/ataque (baixo). Nunca mostrada ao jogador durante o jogo.
- **Inconsistência (contador):** soma quando o jogador contradiz a própria
  escolha anterior. Acima de um limite, força a rota de Colapso.

## Rotas / finais (visão completa, implementadas aos poucos)
1. **Caminho Cinza (neutro):** Poder equilibrado (35-65). Tom agridoce,
   não desolador: "O país não vira utopia, nem colapsa... Você não salvou
   todo mundo. Mas também não desistiu."
2. **A Reforma:** Poder baixo (povo), Integridade alta, sem excessos.
3. **O Mártir:** Poder baixo (povo), Integridade alta, mas arriscou demais.
4. **Repressão Total:** Poder alto (governo), Integridade baixa por medo.
5. **O Vendido:** Poder alto/neutro, Integridade baixa por sensacionalismo.
6. **O Maquiavel:** Integridade muito baixa (ataque constante), qualquer
   Poder. Vira figura de poder própria à custa de quem sacrificou.
7. **O Colapso:** Inconsistência acima do limite. Guerra civil/êxodo.

## Escopo atual (v0, ver docs/SPEC.md para os marcos técnicos)
Primeira fatia: só o eixo Poder decide o final, com 3 finais (Repressão,
Reforma, Cinza). Integridade e Inconsistência entram no modelo de dados
desde já, mas sua lógica de resolução vem em marco futuro.
