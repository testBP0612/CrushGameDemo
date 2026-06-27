extends Node2D

const DataLoaderScript := preload("res://Scripts/core/data_loader.gd")

enum GameState {
	BOOT,
	TITLE
}

@onready var title_screen: Control = $UILayer/TitleScreen
@onready var title_label: Label = $UILayer/TitleScreen/TitleLayout/TitleLabel
@onready var best_record_label: Label = $UILayer/TitleScreen/TitleLayout/BestRecordLabel

var data_loader := DataLoaderScript.new()
var state: GameState = GameState.BOOT


func _ready() -> void:
	_enter_boot()


func _enter_boot() -> void:
	state = GameState.BOOT
	if not data_loader.load_all():
		push_error("BOOT failed: Data/*.json could not be loaded.")
		return

	var balance := data_loader.balance_config()
	print(
		"Data loaded: starting_balance=%s default_bet=%s stage_1_multiplier=%s stage_1_success_rate=%s" %
		[
			balance.get("starting_balance", 0),
			balance.get("default_bet", 0),
			data_loader.multiplier_at(1),
			data_loader.success_rate_at(1)
		]
	)

	_enter_title()


func _enter_title() -> void:
	state = GameState.TITLE
	title_screen.visible = true
	title_label.text = data_loader.text("title_game_name")
	best_record_label.text = data_loader.text("best_record", {"payout": 0})
