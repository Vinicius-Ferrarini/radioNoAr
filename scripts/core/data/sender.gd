class_name Sender
extends Resource

## Quem mandou. Antes do M8B isto era uma string solta dentro do item;
## agora é gente, com nome, cara e jeito de escrever.
##
## O avatar é de propósito ruim: 16x16, escuro, às vezes um ombro ou um
## cachorro em vez de um rosto. O design diz que as pessoas existem por
## voz, letra e uma foto ruim — é isso (ADR 0010).

enum Relationship {
	## Nunca falou com você antes.
	STRANGER,
	## Do bairro. Você reconhece a voz.
	NEIGHBOR,
	## Gente de dentro da rádio.
	FRIEND,
	## Repartição, ministério, emissora estatal.
	OFFICIAL,
	## Não assinou. Pode ser qualquer um, inclusive o governo.
	ANONYMOUS,
}

@export var id: String
@export var display_name: String
## Nome do sprite em assets/sprites/, sem extensão.
@export var avatar: String
## Número, endereço ou protocolo — o que aparece embaixo do nome.
@export var handle: String
@export var relationship: Relationship
## Uma linha sobre como essa pessoa fala. Para quem escreve conteúdo, e
## para o close mostrar em quem o jogador está prestes a confiar.
@export_multiline var voice: String
