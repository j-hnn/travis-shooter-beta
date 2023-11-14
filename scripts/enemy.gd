class_name Enemy extends Area2D

@export var speed = 150
@export var hp = 2

func _physics_process(delta):
	global_position.y += speed * delta

func die():
	print("enemy died")
	queue_free()

func _on_body_entered(body):
	if body is Player:
		body.die()
		die()

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()