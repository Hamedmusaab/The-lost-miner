extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -257.0
var gravity: float = 900.0
var weapon_equip: bool
var is_attacking: bool = false
var is_hurt: bool = false
var facing_right: bool = true  # Track facing direction for attack flip

func _ready() -> void:
	weapon_equip = false
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start attack on press (hold to continue)
			if not is_attacking and not is_hurt:
				start_attack()
		else:
			# End attack on release (stop if holding was interrupted)
			if is_attacking:
				end_attack()

func _physics_process(delta: float) -> void:
	# Don't process movement or other actions if hurt
	if is_hurt:
		# Allow gravity to still apply during hurt state
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jumping") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement (always allowed, even during attack)
	var direction := Input.get_axis("moving_left", "moving_right")
	if direction:
		velocity.x = direction * SPEED
		# Update facing direction
		facing_right = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Handle animations
	if is_attacking:
		# Update flip if moving during attack
		if direction != 0:
			toggle_flip_sprite(direction)
		# Check if attack animation has finished (only end naturally if still holding)
		if animated_sprite.animation == "attack" and not animated_sprite.is_playing():
			# If mouse is still held, restart the attack animation to simulate continuous hold
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				animated_sprite.play("attack")  # Restart for looping effect while held
			else:
				end_attack()
	else:
		handle_movement_animation(direction)

func handle_movement_animation(dir: float) -> void:
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle")
	elif velocity.x != 0:
		animated_sprite.play("run")
		toggle_flip_sprite(dir)
	elif not is_on_floor():
		animated_sprite.play("jump")

func toggle_flip_sprite(dir: float) -> void:
	if dir == 1:
		animated_sprite.flip_h = false
	elif dir == -1:
		animated_sprite.flip_h = true

func start_attack() -> void:
	is_attacking = true
	animated_sprite.speed_scale = 2
	animated_sprite.play("attack")
	# Set initial flip based on facing direction
	animated_sprite.flip_h = not facing_right

func end_attack() -> void:
	is_attacking = false
	animated_sprite.speed_scale = 1.0
	animated_sprite.stop()  # Stop the animation immediately on release

# New function to handle taking damage
func take_damage(damage: int, knockback_force: Vector2 = Vector2.ZERO) -> void:
	if is_hurt:
		return  # Already in hurt state, ignore additional damage
	
	# Apply knockback if specified
	if knockback_force != Vector2.ZERO:
		velocity = knockback_force
	
	# Start hurt animation
	start_hurt_animation()
	
	# Here you would also subtract health, etc.
	# health -= damage

func start_hurt_animation() -> void:
	is_hurt = true
	is_attacking = false  # Cancel any ongoing attack
	
	animated_sprite.play("hurt")
	# Wait for the hurt animation to finish
	await animated_sprite.animation_finished
	
	# Return to normal state after hurt animation
	end_hurt_animation()

func end_hurt_animation() -> void:
	is_hurt = false
	animated_sprite.stop()  # Stop the hurt animation
	# Resume normal animation based on current state
	handle_movement_animation(Input.get_axis("moving_left", "moving_right"))
