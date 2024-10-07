extends SceneletTrigger

@export var guitar_scenelet: SceneletTrigger


func _ready() -> void:
    Game.guitar_strummed.connect(self._on_guitar_strummed, ConnectFlags.CONNECT_ONE_SHOT)


func _on_guitar_strummed() -> void:
    self.guitar_scenelet.start()
