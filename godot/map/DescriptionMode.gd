extends Control

export var gamemode : Resource setget set_gamemode

onready var animator = $AnimationPlayer

onready var rule1 = $Rule1
onready var rule2 = $Rule2

signal ready_to_fight

func _ready():
	refresh()
	$Description2.modulate *= Color(1,1,1,0)

func refresh():
	if $Sprite and gamemode:
		#$Sprite.texture = gamemode.logo
		"""
		sport_name.text = tr(gamemode.description).format({
			"score": str(gamemode.max_score),
			"time": str(gamemode.max_timeout)
		})
		"""
		$Sprite/Label.text = tr(gamemode.name)
		
		var i = 1
		for rule in gamemode.rules:
			get_node("Rule"+str(i)).apply_rule(rule)
			i+=1
		
		"""
		if "shoot_bombs" in gamemode and not gamemode["shoot_bombs"]:
			$Description3.text = 'No bombs!'
		elif "starting_ammo" in gamemode and gamemode["starting_ammo"] != -1:
			$Description3.text = 'Limited ammo!'
		"""
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()

signal letsfight

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		yield(get_tree().create_timer($Timer.time_left), 'timeout')
		disappears()

func appears():
	visible = true
	animator.play("getin")
	yield(animator, "animation_finished")
	$AudioStreamPlayer.play()
	animator.play("describeme")
	
func disappears():
	animator.play("getout")
	$Description2.queue_free()
	yield(animator, "animation_finished")
	emit_signal("ready_to_fight")
	queue_free()

func demomode(demo = false):
	$Description2.visible = not demo
