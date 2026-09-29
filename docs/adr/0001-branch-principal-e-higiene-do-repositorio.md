# 0001 — Branch principal e higiene do repositório

- **Status:** aceito (decisão do dono do repositório em 2026-09-29)
- **Data:** 2026-09-29

## Contexto

Estado verificado no repositório:

- `master` tem todo o trabalho (M0–M3, commits `Projeto`, `prototipo`,
  `inicial`) e **não tem `.gitignore`**.
- `main` tem um único commit (`Initial commit`) com **apenas** o
  `.gitignore` padrão do Godot.
- `git merge-base master main` não devolve nada: as duas branches **não
  têm ancestral comum**.
- `origin/HEAD` aponta para `main`, ou seja, quem abre o GitHub vê a
  branch quase vazia como a principal.
- `git ls-files .godot | wc -l` = **171 arquivos** de cache do editor
  versionados (layout do editor, folding de scripts, cache de fontes,
  `uid_cache.bin`). Isso gera conflito garantido em qualquer trabalho a
  mais de uma máquina e polui todo diff.

## Decisão

Três partes, executadas no M4:

1. **Branch principal: `master`**, porque é onde está todo o histórico
   real. `origin/HEAD` passa a apontar para `master` e `main` é
   descartada como branch órfã, depois de trazer o `.gitignore` dela. A
   alternativa (adotar `main`) exigiria
   `git merge --allow-unrelated-histories` ou reescrever a história, sem
   ganho.
2. **Trazer o `.gitignore`** do commit de `main` para a raiz da branch
   principal, sem alteração (já cobre `.godot/`, `.import/`, `*.tmp`,
   `.mono/`, `data_*/`, `mono_crash.*.json`).
3. **Remover o cache do versionamento** com
   `git rm -r --cached .godot`, em um commit isolado
   ("remove cache do editor do versionamento"). Os arquivos continuam no
   disco; só param de ser rastreados.

## Alternativas consideradas

- **Manter as duas branches como estão.** Rejeitado: `origin/HEAD` em
  `main` faz o repositório parecer vazio e convida a commits na branch
  errada.
- **Fazer `main` absorver `master` com merge de históricos não
  relacionados.** Rejeitado: cria um merge artificial e um histórico
  confuso, para ganhar apenas o nome "main".
- **Manter `.godot/` versionado** para que um clone abra sem reimportar.
  Rejeitado: o reimport é automático no primeiro `--headless --import` e
  o custo em conflitos é alto. `CLAUDE.md` já documenta o comando.

## Consequências

- Um clone novo precisa rodar
  `Godot_v4.7.2-stable_mono_win64.exe --headless --import` antes da
  primeira execução dos testes. Isso passa a estar no `CLAUDE.md`.
- `.godot/` sai dos diffs e o histórico fica legível.
- Apagar `main` no remoto exige trocar a branch padrão no GitHub antes
  (Settings → Branches), senão o `git push origin --delete main` é
  recusado. Isso é feito à mão pelo dono do repositório; o M4 avisa
  quando chegar nesse ponto.
