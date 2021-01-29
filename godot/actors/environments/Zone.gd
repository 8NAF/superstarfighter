tool
extends Area2D

export var max_time = 10

var active setget set_active, get_active
var player setget set_player, get_player

signal lost

func set_active(v):
	active = v
	
	$Background.visible = active
	$Border.self_modulate = Color(1,1,1) if active else Color(1,1,1,0.2)
	
	if active:
		add_to_group('in_camera')
	else:
		remove_from_group('in_camera')
		
func get_active():
	return active
	
func set_player(v):
	player = v
	
	if player != null:
		$Background.modulate = player.species.color
		$Border.modulate = player.species.color
		$Wrapper/Monogram.modulate = player.species.color
		$Wrapper/Monogram.text = player.species.get_monogram()
	else:
		$Background.modulate = Color(1,1,1)
		$Border.modulate = Color(1,1,1)
		$Wrapper/Monogram.modulate = Color(1,1,1)
		$Wrapper/Monogram.text = ''
		
func get_player():
	return player

func _ready():
	refresh_polygon()
	$GShape.connect('changed', self, 'refresh_polygon')
	$Timer.wait_time = max_time
	set_process(false)
	
func _process(delta):
	$Background.material.set_shader_param('time_left', max_time - $Timer.time_left)
	
func refresh_polygon():
	var polygon = $GShape.to_PoolVector2Array()
	$CollisionPolygon2D.polygon = polygon
	$Background.polygon = polygon
	$Border.points = $GShape.to_closed_PoolVector2Array()
	
func take_control(p):
	set_player(p)
	set_process(true)
	$Timer.start(max_time)
	$Background.material.set_shader_param('max_time', max_time)
	
func lose_control():
	set_player(null)
	set_process(false)
	set_active(false)
	$Timer.stop()
	$Timer.wait_time = max_time
	emit_signal('lost', self)
	
func _on_Zone_body_entered(body):
	if active and body is Ship and get_player() == null:
		take_control(body.get_player())
		
func _on_Zone_body_exited(body):
	if active and body is Ship and body.get_player() == player:
		lose_control()
	
func _on_Timer_timeout():
	lose_control()
	
