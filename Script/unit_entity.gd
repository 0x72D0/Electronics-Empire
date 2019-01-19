extends "entity.gd"

var code = PoolStringArray()
var code_pos
var id

signal unit_dead_signal

remote func ask_entity_sync():
	rpc("entity_sync", self.sprite.animation, self.sprite.frame, self.position, self.health_bar.value, self.orientation, self.code_pos, self.code )
	pass

remote func entity_sync(animation, frame, pos, health, orientation, code_pos, code):
	self.sprite.animation = animation
	self.sprite.frame = frame
	self.position = pos
	self.health_bar.value = health
	self.orientation = orientation
	self.code_pos = code_pos
	self.code = code
	send_line()
	pass

sync func send_line():
	
	if(code[code_pos] == ""):
		__reset_active__()
	self.interpreter.load_line(code[code_pos])
	
	self.clock_bar.show()
		
	self.clock.start()
	yield(self.clock, "timeout")
		
	self.clock_bar.hide()
	
	self.interpreter.evaluate()
	if(self.interpreter.error_occur):
		__explode__()
	else:
		print(self.interpreter.registers["x"])
		print(self.interpreter.registers["y"])
		print(self.interpreter.registers["a"])
	
	pass

func load_code(code):
	self.code = code
	pass

func _ready():
	._ready()
	self.code_pos = 0
	pass

func __die__():
	emit_signal("unit_dead_signal")

func __explode__():
	self.__die__()
