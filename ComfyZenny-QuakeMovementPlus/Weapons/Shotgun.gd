extends Spatial

export var fire_rate = 1.0
export var clip_size = 6
export var reload_rate = .8
export var fire_range = 800
export var damage = 200
export var spread = 100

onready var raycast = $Camera/RayCast
onready var raycast_container = $Camera/RayCastContainer
onready var anim_player = $AnimationPlayer

var current_ammo = clip_size
var can_fire = true
var reloading = false

func _ready():
	raycast.cast_to = Vector3(0, 0, -fire_range)
	randomize()

func _physics_process(delta):
	if Input.is_action_just_pressed("Reload"):
		reload()

func fire():
	if Input.is_action_pressed("PrimaryFire") and can_fire:
		if current_ammo > 0 and not reloading:
			if not anim_player.is_playing():
				anim_player.play("ShotgunFire")
				can_fire = false
				current_ammo -= 1
				check_collision()
				yield(get_tree().create_timer(fire_rate), "timeout")
				can_fire = true
		elif not reloading:
			reload()

func check_collision():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("HasHealth"):
			var distance = raycast.global_transform.origin.distance_to(collider.global_transform.origin)
			var calculated_damage = damage / distance
			collider.health -= calculated_damage
			for r in raycast_container.get_children():
				r.cast_to.x = rand_range(spread, -spread)
				r.cast_to.y = rand_range(spread, -spread)
				if r.is_colliding():
					if r.get_collider().is_in_group("HasHealth"):
						r.get_collider().health -= calculated_damage

func reload():
	anim_player.stop()
	reloading = true
	yield(get_tree().create_timer(reload_rate), "timeout")
	current_ammo = clip_size
	reloading = false
