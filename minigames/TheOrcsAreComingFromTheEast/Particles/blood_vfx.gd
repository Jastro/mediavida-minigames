extends GPUParticles2D

func _ready():
	finished.connect(queue_free)
