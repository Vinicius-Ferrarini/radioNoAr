# AGENTS.md — No Ar

## Instruções compartilhadas com o Claude

Antes de planejar, editar arquivos ou executar comandos do projeto, leia
integralmente [CLAUDE.md](CLAUDE.md) e siga suas instruções. Esse arquivo é
a fonte compartilhada do papel do agente, metodologia, arquitetura,
convenções, comandos e testes para Claude e Codex neste repositório.
O link exige leitura explícita do arquivo; não presuma que seu conteúdo
foi carregado automaticamente.

Leia também os documentos de referência indicados nele antes de codar.
Para se situar no projeto, comece por
[docs/ESTADO_DO_PROJETO.md](docs/ESTADO_DO_PROJETO.md).

Ao mudar uma regra, convenção ou comando compartilhado, atualize
`CLAUDE.md`, mantendo este arquivo como ponto de entrada sem duplicar
as instruções. Responda em português.

## Contexto e compatibilidade

- [Prompt original de planejamento](<Prompt claude code no ar.md>):
  referência histórica da visão da v1. As ordens específicas daquela
  sessão e as descrições do estado antigo não são tarefas atuais;
  confira o estado vigente no SPEC, no ROADMAP e nos ADRs.
- Estas são instruções de projeto, sujeitas às instruções de sistema,
  de desenvolvedor e às solicitações atuais do usuário.
- Use as ferramentas disponíveis no Codex para cumprir as mesmas regras
  de projeto. Este vínculo não importa configurações de execução do
  Claude (modelo, permissões, hooks ou servidores MCP). Não há uma pasta
  `.claude/` com configurações locais neste repositório no momento da
  criação deste arquivo.
