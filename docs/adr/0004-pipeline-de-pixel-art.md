# 0004 — Pipeline de pixel art gerada por script

- **Status:** aceito
- **Data:** 2026-09-29

## Contexto

A arte precisa ser produzida por mim (Claude), de forma reproduzível, sem
um humano abrindo editor de imagem, e sem adicionar dependências ao
projeto. Também precisa ser revisável: um diff de PNG binário não diz
nada, mas um diff de mapa de pixels em texto diz tudo.

## Decisão

Gerador em GDScript rodado pelo próprio Godot em modo headless.

- Cada sprite é **dado em texto**: `tools/pixelart/sprite_defs/<nome>.gd`
  com `static func definition() -> Dictionary` contendo `name`, `size`,
  `legend` (caractere → nome de cor da paleta, `""` = transparente) e
  `rows` (`PackedStringArray`, um caractere por pixel).
- `tools/pixelart/palette.gd` (`class_name PixelPalette`) é a única fonte
  de cor. Nenhum literal de cor em definição de sprite.
- `tools/pixelart/sprite_builder.gd` (`PixelSpriteBuilder.build(def) -> Image`)
  é **puro, sem I/O**, para poder ser chamado direto de um teste GUT.
- `tools/pixelart/generate.gd` é o único que escreve em disco:
  `Image.save_png()` em `assets/sprites/<name>.png` + um
  `assets/sprites/manifest.json` com nome, caminho, dimensões, `sha256`
  dos bytes RGBA e as cores usadas.

```
C:\Godot\Godot_v4.7.2-stable_mono_win64.exe --headless -s tools/pixelart/generate.gd
```

- Os PNGs **são versionados** (quem clona não precisa gerar para jogar), e
  o gerador é determinístico: ordem alfabética por `name`, sem RNG, sem
  timestamp. Duas execuções seguidas não mudam um byte.
- `tests/unit/test_asset_manifest.gd` é o portão: manifesto completo,
  PNGs existentes, dimensões corretas, todas as cores dentro da paleta,
  `build` determinístico e definições bem formadas (SPEC §6).
- Filtro de textura `Nearest` no projeto (ADR 0005).
- Nada de `_draw()` em cena nenhuma: os PNGs entram via `TextureRect` e
  `NinePatchRect`, editáveis no editor.

## Alternativas consideradas

- **Aseprite / editor externo.** Rejeitado: dependência fora do repo,
  arquivo binário opaco no diff, e não é reproduzível por mim.
- **Gerar com Python + Pillow.** Rejeitado: adiciona runtime e
  dependência que o projeto não tem, para fazer o que a classe `Image` do
  Godot já faz.
- **Gerar SVG e rasterizar.** Rejeitado: pixel art quer controle de pixel
  individual; vetor é a ferramenta errada.
- **Gerar em tempo de execução** (sem PNGs versionados). Rejeitado: custa
  tempo de carregamento, impede revisar a arte no GitHub e torna a arte
  invisível para o editor do Godot.

## Consequências

- Sprites grandes viram arquivos de texto grandes (um caractere por
  pixel). Aceitável até ~64×64; acima disso a definição passa a ser
  composta por primitivas (retângulos, linhas, gradiente de dithering) em
  vez de mapa literal. O `sprite_builder` precisa suportar as duas formas
  — mapa e lista de primitivas — desde o M7.
- Regenerar arte é uma etapa manual antes do commit. Como o teste de
  manifesto compara o `sha256`, esquecer de regenerar quebra a suíte.
- A arte fica em estilo "programador disciplinado", não em estilo de
  artista. É a troca aceita para ter arte versionada e reproduzível.
