class_name ReplyOption
extends Resource

## O que você manda de volta. É a superfície diegética de um
## FramingOption que o item já declara: a consequência, o roteiro e a
## exigência de evidência continuam morando no enquadramento (ADR 0013).
##
## Dizer que não vai falar do assunto é uma resposta como as outras
## (Kind.DISCARD), não a ausência de uma.

@export var id: String
@export_multiline var text: String
@export var framing_kind: FramingOption.Kind
## O que a pessoa responde depois de você mandar isso.
@export var answer: Array[ChatMessage]
