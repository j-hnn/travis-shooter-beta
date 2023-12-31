extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var power_up_scenes: Array[PackedScene] = []

@onready var player_spawn_pos = $PlayerSpawnPos
@onready var laser_container = $LaserContainer
@onready var timer = $EnemySpawnTimer
@onready var putimer = $PowerUpSpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var hud = $UILayer/HUD
@onready var gos = $UILayer/GameOverScreen
@onready var pb = $ParallaxBackground
@onready var puc = $PowerUpContainer

@onready var laser_sound = $SFX/LaserSound
@onready var hit_sound = $SFX/HitSound
@onready var explode_sound = $SFX/ExplodeSound

var player = null
var score := 0:
	set(value):
		score = value
		hud.score = score
var high_score

var scroll_speed = 100

func _ready():
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file!=null:
		high_score = save_file.get_32()
	else:
		high_score = 0
		save_game()
	
	score = 0
	player = get_tree().get_first_node_in_group("player")
	assert(player!=null)
	player.global_position = player_spawn_pos.global_position
	player.laser_shot.connect(_on_player_laser_shot)
	player.killed.connect(_on_player_killed)

func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(high_score)

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		print("quit")
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		print("reloaded scene")
		
	if timer.wait_time > 0.1:
		timer.wait_time -= delta * 0.05
	elif timer.wait_time < 0.1:
		timer.wait_time = 0.1
		
	pb.scroll_offset.y += delta * scroll_speed
	if pb.scroll_offset.y >= 960:
		pb.scroll_offset.y = 0


func _on_player_laser_shot(laser_scene, location): 
	var laser = laser_scene.instantiate()
	laser.global_position = location
	laser_container.add_child(laser)
	laser_sound.play()

func _on_enemy_spawn_timer_timeout():
	var enemy = enemy_scenes.pick_random().instantiate()
	enemy.global_position = Vector2(randf_range(50, 500), 0)
	enemy.killed.connect(_on_enemy_killed)
	enemy.hit.connect(_on_enemy_hit)
	enemy_container.add_child(enemy)

func _on_enemy_killed(points):
	hit_sound.play()
	score += points
	if score > high_score:
		high_score = score
		
func _on_enemy_hit():
	hit_sound.play()

func _on_player_killed():
	explode_sound.play()
	gos.set_score(score)
	gos.set_high_score(high_score)
	save_game()
	await get_tree().create_timer(1.5).timeout
	gos.visible = true


func _on_power_up_spawn_timer_timeout():
	var powerups = power_up_scenes.pick_random().instantiate()
	powerups.global_position = Vector2(randf_range(50, 500), 0)
	puc.add_child(powerups)
