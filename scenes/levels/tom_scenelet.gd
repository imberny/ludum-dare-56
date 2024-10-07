extends SceneletTrigger

@export var guitar_scenelet: SceneletTrigger
@export var arpeggio_scenelet: SceneletTrigger


func _ready() -> void:
	Game.guitar_picked_up.connect(self._on_guitar_picked_up, ConnectFlags.CONNECT_ONE_SHOT)
	Game.arpeggio.connect(self._arpeggio, ConnectFlags.CONNECT_ONE_SHOT)


func _on_guitar_picked_up() -> void:
	self.guitar_scenelet.start()


func _arpeggio() -> void:
	self.arpeggio_scenelet.start()
