class_name ForbiddenWordSlot
extends Resource

## Uma palavra proibida escondida no roteiro. Aparece sem destaque: quem
## tem que lembrar da circular desta semana é o apresentador, não a
## interface. Clicar troca pelo sinônimo aprovado; deixar passar é
## infração anotada pelo regime.

@export var word: String
## Posição da palavra dentro do texto da linha.
@export var char_start: int
@export var approved_synonym: String
