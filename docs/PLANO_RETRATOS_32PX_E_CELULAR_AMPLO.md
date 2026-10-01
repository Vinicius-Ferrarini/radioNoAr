# Plano — retratos 32 px e celular amplo

## Objetivo

Aproximar os contatos do celular da personalidade da folha conceitual da
noite 1, sem abandonar a resolução base 320×180 nem o pipeline determinístico
de pixel art.

## Decisão visual

- Redesenhar os cinco retratos da noite 1 em 32×32 pixels nativos.
- Usar cenário, iluminação e roupa como parte da identificação do contato.
- Ampliar o aparelho de 136×156 para 156×166 pixels.
- Usar linhas de 38 px na lista, com três contatos inteiros e rolagem.
- Exibir no chat uma faixa de contato com retrato 32×32, nome e identificação.
- Mover o fechar para a linha superior da moldura, liberando o cabeçalho.
- Manter as escolhas no painel externo à direita.

## Retratos

- **Dona Célia:** coque grisalho, óculos dourados, cardigan vermelho, roupa
  estampada e interior doméstico.
- **Oficina do Portão Doze:** portão numerado, luz de serviço, ferramenta e
  caixa vermelha; não representa uma pessoa.
- **J. Toledo:** rosto frontal, sobrancelhas marcadas, terno, gravata e papéis.
- **Rui:** boné, uniforme, volante e janela azul da cabine.
- **Nilo:** fones, óculos, ferramenta e equipamentos âmbar do estúdio.

## Implementação

1. Atualizar SPEC e registrar a decisão no ADR 0018.
2. Escrever testes de tamanho dos assets, dimensões do aparelho, posição do
   fechar, coluna do retrato e faixa de contato.
3. Redesenhar os cinco `sprite_defs` em 32×32 e regerar o manifesto.
4. Reorganizar `close_phone.tscn` e `phone_thread_row.tscn`.
5. Passar a identificação do remetente para a apresentação do chat.
6. Rodar importação, suíte completa, geração determinística e QA renderizado.

## Critérios de aceite

- Os cinco PNGs têm exatamente 32×32 e usam somente a paleta do projeto.
- A lista mostra retrato, nome, hora e prévia sem sobreposição.
- O chat mostra retrato, nome e identificação antes das mensagens.
- O fechar fica na faixa superior, acima do título/conversa.
- Celular e painel de decisão permanecem dentro de 320×180.
- Suíte completa e treze capturas de QA passam.

## Resultado executado

- Cinco retratos 32×32 regenerados com rosto, roupa, iluminação e cenário.
- Aparelho 156×166 com três contatos inteiros e rolagem para os demais.
- Faixa de conversa com retrato, nome e identificação do contato.
- Fechar movido para a moldura superior.
- Suíte completa: 349/349 testes, 211.414 asserts.
- QA renderizado: treze capturas e navegação até a terceira noite.
