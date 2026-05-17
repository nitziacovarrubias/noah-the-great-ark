extends CharacterBody2D
@export var capture_ball_projectile_scene: PackedScene = preload("res://scenes/projectiles/CaptureBallProjectile.tscn")

@onready var throw_point: Marker2D = $ThrowPoint
var last_direction := Vector2.RIGHT
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var respawn_particles: GPUParticles2D = $RespawnParticles

const SPEED := 170.0
const JUMP_VELOCITY := -360.0
const GRAVITY := 980.0

var is_crouching := false

func _ready() -> void:
	print("Player listo")


func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Detectar si está agachado
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()

	# Movimiento izquierda / derecha
	var direction := Input.get_axis("move_left", "move_right")

	if is_crouching:
		velocity.x = 0
	else:
		velocity.x = direction * SPEED

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	# Voltear personaje
	if direction != 0:
		animated_sprite.flip_h = direction < 0
		
	if direction > 0:
		last_direction = Vector2.RIGHT
	elif direction < 0:
		last_direction = Vector2.LEFT

	# Animaciones
	update_animation(direction)

	move_and_slide()

func throw_capture_ball() -> void:
	if not GameState.has_capture_ball:
		print("You need the Capture Ball first.")
		return

	var projectile = capture_ball_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = throw_point.global_position
	projectile.setup(last_direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_capture_ball"):
		throw_capture_ball()

func update_animation(direction: float) -> void:
	if is_crouching:
		play_animation("crouch")
	elif not is_on_floor():
		if velocity.y < 0:
			play_animation("jump")
		else:
			play_animation("fall")
	elif direction != 0:
		play_animation("walk")
	else:
		play_animation("idle")


func play_animation(animation_name: String) -> void:
	if animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name:
			animated_sprite.play(animation_name)
	else:
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
			
			
func _on_water_body_entered(body: Node2D) -> void:
	if body == self:
		respawn_player()

func respawn_player() -> void:
	global_position = GameState.get_respawn_position()
	velocity = Vector2.ZERO
	play_respawn_effect()

func play_respawn_effect() -> void:
	respawn_particles.emitting = false
	respawn_particles.restart()
	respawn_particles.emitting = true
