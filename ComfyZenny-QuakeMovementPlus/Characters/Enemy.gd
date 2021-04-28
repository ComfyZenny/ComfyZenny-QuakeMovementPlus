extends StaticBody

var health = 100

func _process(delta):
	if health <= 0:
		queue_free()
