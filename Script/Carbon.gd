extends StaticBody2D

var ressource_name = "carbon"
var owner_id = 0

func mine():
	self.queue_free()
	return 1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
