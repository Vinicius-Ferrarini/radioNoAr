class_name ImprovPoint
extends Resource

## O roteiro para e o relógio corre. É onde o jogador fala por conta
## própria, com tempo contado.

@export var id: String
## O que o momento pede. Aparece curto, na tela, junto com o relógio.
@export var prompt: String
@export var time_limit_seconds: float = 6.0
## O índice 0 é a opção padrão: é ela que entra quando o tempo estoura.
## Escreva sempre a mais covarde ou a mais neutra no índice 0.
@export var options: Array[ImprovOption]
