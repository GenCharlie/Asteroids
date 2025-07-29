extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spwan_area: Area2D = $PlayerSpawnPos/PlayerSpwanArea
@onready var laser_sound: AudioStreamPlayer = $Music/LaserSound

var asteroid_scene = preload("res://Scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives = 3:
	set(value):
		lives = value 
		hud.init_lives(lives)



func _ready():
	game_over_screen.visible = false 
	score = 0
	lives = 3
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_player_laser_shot(laser):
	$Music/LaserSound.pitch_scale = randf_range(0.85,1)
	$Music/LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size, points):
	$Music/AsteroidHitSound.play()
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass
	print(score)

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)

func _on_player_died():
	$Music/PlayerDieSound.play()
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives <= 0:
		await get_tree().create_timer(1).timeout
		game_over_screen.visible = true 
	else:
		await get_tree().create_timer(1).timeout
		while !player_spwan_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)
		
