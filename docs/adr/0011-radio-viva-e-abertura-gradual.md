# 0011 — Rádio viva e abertura gradual

- Status: aceito — execução autorizada pelo usuário em 2026-09-29.

## Contexto

A fatia anterior começa no auge da repressão, repete leitura e deixa
ligação e som fora da experiência. O pedido atual autoriza revisar o
design e executar uma abertura que comece na rotina da rádio.

## Decisão

Executar `docs/PLANO_RADIO_VIVA.md`. Reação imediata e repercussão tardia
substituem a proibição absoluta de reação na mesma noite. Conservar as
três camadas, os nós Control e o pipeline do ADR 0004.

Criar `data/pilot/` como campanha inicial selecionável. Preservar a
noite anterior em `data/nights/` para regressão, com seleção explícita
nos testes antigos. Não apagar testes. Ajustar os testes de UI que
exigiam esconder ferramentas ao vivo: agora elas continuam disponíveis.
Adicionar testes próprios de conteúdo e integração da abertura.

Enquadramentos podem exigir uma evidência cruzada. O rótulo é escrito
por item; não há promessa genérica de verdade. Intervalo único por noite
oferece música (vínculo) ou anúncio (caixa/patrocinador). Microfone passa
a chave alternável na UI, preservando a API de estado da lógica.

O alinhamento continua no modelo para compatibilidade, mas a abertura
comunica relações por respostas e objetos, sem barra de facção. Mudança
de enquadramento respaldada por contradição apurada não soma
inconsistência: substitui parcialmente a regra do SPEC §4.8.

## Alternativas

- Completar 21 noites primeiro: aumenta conteúdo antes de provar o loop.
- Reescrever a arquitetura: desnecessário, a separação atual é aproveitável.
- Importar ilustrações fora da paleta: perde reprodutibilidade; os novos
  assets seguem mapas de pixels e o gerador existente.

## Consequências

Introduz campos opcionais e uma campanha de três noites com testes de
ambos os caminhos. Áudio sintetizado original é provisório, sem dublagem
completa. Finais, gestão diária completa e campanha longa seguem futuros.
