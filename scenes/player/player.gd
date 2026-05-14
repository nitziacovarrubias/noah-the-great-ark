extends CharacterBody2D

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

	# Animaciones
	update_animation(direction)

	move_and_slide()


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
		global_position = Vector2(70, -200)
		velocity = Vector2.ZERO
		play_respawn_effect()

func play_respawn_effect() -> void:
	respawn_particles.emitting = false
	respawn_particles.restart()
	respawn_particles.emitting = true
