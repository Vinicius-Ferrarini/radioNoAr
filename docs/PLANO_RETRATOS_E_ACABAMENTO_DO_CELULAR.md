# Plano — retratos da noite 1 e acabamento do celular

## Objetivo

Dar identidade imediata às conversas da primeira noite e corrigir os dois
ruídos visuais apontados no playtest: a aba recolhida do roteiro quase
invisível e os balões com uma ponta que parece um retângulo borrado.

## Diagnóstico

1. **Aba do roteiro:** quando a folha recolhe, o `NinePatchRect` de papel é
   escondido e sobra somente um `Label` em tinta escura sobre a mesa escura.
   Não existe moldura própria para comunicar que ele é clicável.
2. **Abertura sem retorno:** ao receber uma decisão, `_animate_attention()`
   abre a folha e retorna. Ele não registra que a folha estava recolhida nem
   agenda o fechamento depois da animação do cartão.
3. **Contatos sem rosto:** os remetentes já apontam para avatares, mas a lista
   e o cabeçalho do chat não os apresentam. Os cinco sprites da noite 1 também
   são silhuetas genéricas demais para a função atual.
4. **Borda irregular:** `bubble_them.png` e `bubble_me.png` têm uma ponta
   lateral intencional. Ao esticar a textura como nine-patch, a ponta aparece
   como uma pequena sobra abaixo ou ao lado da caixa. Para o novo desenho,
   cada mensagem deve ser um retângulo de limites exatos.

## Escopo da primeira noite

| Contato | Leitura visual do retrato |
|---|---|
| Dona Célia | senhora idosa, coque grisalho, óculos e roupa quente de bairro |
| Oficina do Portão Doze | fachada/oficina mecânica, portão, ferramenta e luz de trabalho; não é uma pessoa |
| J. Toledo | homem tenso e categórico, foto frontal, sobrancelhas marcadas |
| Rui, motorista | motorista de boné, uniforme e enquadramento de cabine |
| Nilo, o técnico | técnico de óculos, fones e ferramenta, luz âmbar do estúdio |

Somente esses cinco avatares serão redesenhados. O conceito visual pode ser
gerado como referência, mas os assets usados pelo jogo continuarão definidos
em `tools/pixelart/sprite_defs/`, limitados à paleta e reproduzíveis pelo
gerador do projeto.

Referência produzida: `docs/references/retratos-noite-1-conceito.png`.

## Implementação planejada

### 1. Contrato visual e testes

- Registrar a decisão no ADR 0017 e no SPEC antes do código.
- Acrescentar testes para:
  - os cinco contatos da primeira noite terem avatares existentes;
  - lista e cabeçalho da conversa exibirem a textura correta;
  - a linha reservar uma coluna ao retrato sem esconder a hora;
  - os balões usarem caixas retangulares sem ponta/overhang;
  - a aba recolhida ter texto e borda claros;
  - uma pauta nova abrir e recolher automaticamente a folha quando ela
    começou fechada.

### 2. Retratos determinísticos

- Criar uma folha de referência com os cinco motivos, na paleta e no clima
  visual do jogo.
- Redesenhar `avatar_celia`, `avatar_valvula`, `avatar_toledo`, `avatar_rui`
  e `avatar_nilo` em 20×20 pixels.
- Regerar PNGs e `assets/sprites/manifest.json` pelo comando oficial.

### 3. Lista e conversa

- Passar o nome do asset do remetente em `GameState.phone_threads()`.
- Adicionar `TextureRect` de 20×20 à linha de conversa e aumentar a linha para
  25 px, preservando áreas separadas para nome, hora e prévia.
- Adicionar um retrato compacto ao cabeçalho da conversa; o título se desloca
  sem disputar espaço com voltar e fechar.
- Manter filtro nearest e `stretch_mode = KEEP_ASPECT_CENTERED`.

### 4. Balões regulares

- Substituir os `StyleBoxTexture` com ponta por `StyleBoxFlat` retangulares,
  mantendo as duas cores, a borda superior e inferior e as margens atuais.
- Conferir que altura variável, quebra de linha, alinhamento e rolagem na
  primeira não lida continuam funcionando.

### 5. Roteiro transitório

- Dar à aba recolhida fundo escuro, borda branca de 1 px e texto branco.
- Ao chegar uma pauta com a folha fechada: abrir, receber o cartão, permanecer
  legível por um instante e recolher.
- Se a folha já estava aberta por escolha do jogador, apenas executar o breve
  movimento de atenção e mantê-la aberta.
- Cancelar tweens pendentes ao clicar ou receber outra pauta para impedir
  estados visuais conflitantes.

## Validação

1. Gerar assets duas vezes e confirmar manifesto idêntico.
2. Rodar importação headless.
3. Rodar a suíte GUT completa.
4. Executar o QA visual da noite 1 e capturar pelo menos a lista, uma conversa
   e o roteiro durante/depois da transferência.
5. Verificar manualmente em escala inteira que nenhum balão tem saliência,
   nome/hora não se sobrepõem e a aba é legível sobre a mesa.

## Resultado executado

- Cinco retratos 20×20 integrados à lista e ao cabeçalho do chat.
- Balões convertidos para caixas retangulares de limites exatos.
- Aba do roteiro com texto e borda brancos.
- Abertura temporária testada também para duas respostas em sequência.
- Manifesto regenerado duas vezes com SHA-256 idêntico.
- Suíte completa: 347/347 testes, 208.280 asserts.
- QA renderizado: treze capturas e navegação até a terceira noite.
