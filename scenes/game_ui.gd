extends CanvasLayer

var generators_unlocked : int :
	set(val):
		generators_unlocked = val 
		$Generator.text = "Generators: {0}/3".format([val])


func _ready() -> void:
	$Floor.text = "Floor: -{0}".format([GameManager.rounds_won+1])
	SignalBus.generator_activated.connect(func(): generators_unlocked += 1)
