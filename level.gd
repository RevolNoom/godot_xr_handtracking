extends StaticBody3D


var this_wave_droids := []

const _DOORS = 0
const _DROIDS = 1
# next_waves[wave_index][_DOORS] = doors array
# next_waves[wave_index][_DROIDS] = droids array



@onready var next_waves = [
	[[], []],
	[[$Door/D1], 
		[$SpawnPoint/SP1/Path3D/PathFollow3D/RT/SuperBattleDroid]
	],
	[[$Door/D2], 
		[$SpawnPoint/SP2/Path3D/PathFollow3D/RT/SuperBattleDroid,
		$SpawnPoint/SP2/Path3D2/PathFollow3D/RT/SuperBattleDroid]
	],
	[[$Door/D3, $Door/D4], 
		[$SpawnPoint/SP3/Path3D/PathFollow3D/RT/SuperBattleDroid,
		$SpawnPoint/SP3/Path3D2/PathFollow3D/RT/SuperBattleDroid,
		$SpawnPoint/SP3/Path3D3/PathFollow3D/RT/SuperBattleDroid,
		$SpawnPoint/SP3/Path3D4/PathFollow3D/RT/SuperBattleDroid
		]
	]	
]

func _ready():
	#$SpawnPoint/SP0/RT/B2BattleDroid.die()
	pass
	
func start_next_wave():
	next_waves.pop_front()
	if next_waves.size() == 0:
		return
	
	for door in next_waves.front()[_DOORS]:
		door.open()
		door.connect("opened", _on_door_opened)
		
	this_wave_droids = next_waves.front()[_DROIDS]
	for droid in this_wave_droids:
		droid.walk()
		droid.connect("died", _on_droid_died)


func _on_door_opened(_door):
	for droid in next_waves.front()[_DROIDS]:
		droid.attack()


func _on_droid_died(droid):
	this_wave_droids.erase(droid)
	if droid.is_connected("died", _on_droid_died):
		droid.disconnect("died", _on_droid_died)
	if this_wave_droids.is_empty():
		start_next_wave()


func _process(delta):
	for droid in this_wave_droids:
		var pathfollow = droid.get_parent().get_parent() as PathFollow3D
		if pathfollow: 
			if pathfollow.progress_ratio < 1:
				pathfollow.progress += droid.speed * delta
			else:
				#droid.die()
				droid.hold_position()


func _on_starting_battle_droid_died(droid):
	$SpawnPoint/SP0/RT/B2BattleDroid/Label3D.hide()
	_on_droid_died(droid)

