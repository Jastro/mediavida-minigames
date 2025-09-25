extends PanelContainer

var partial_score_scn	: PackedScene
var wincon				: bool	= false
var total_score			: int	= 0

var difficulty_label = {
	GameManager.Difficulty.EASY		: "Easy",
	GameManager.Difficulty.NORMAL	: "Normal",
	GameManager.Difficulty.HARD		: "Hard",
}

func _ready():
	partial_score_scn = preload("res://minigames/TheOrcsAreComingFromTheEast/gui/game_score/partial_score.tscn")
	%FinishGame.pressed.connect(_on_finish_game)
func setup(scores, wincon_set):
	%ScoreLabel.text += " " + difficulty_label[GameManager.get_difficulty()]
	wincon = wincon_set
	var tween = create_tween()
	modulate = Color.TRANSPARENT
	tween.tween_property(self, "modulate", Color.WHITE, 1)
	tween.play()
	await tween.finished
	tween.kill()
	for score in scores:
		var partial_score = partial_score_scn.instantiate()
		%PartialScoreContainer.add_child(partial_score)
		partial_score.initialise(score["attribute"], score["value"], score["total"])
		tween = create_tween().set_ease(Tween.EASE_OUT_IN)
		tween.tween_method(update_total_score, total_score, total_score+score["value"] * score["multiplier"], 0.4).set_delay(0.9)
		tween.play()
		await partial_score.Finished
		tween.kill()
		total_score += score["value"] * score["multiplier"]
	if(GameManager.get_difficulty() > GameManager.Difficulty.NORMAL):
		%TotalScore.text += " * 2"
		tween = create_tween().set_ease(Tween.EASE_OUT_IN)
		tween.tween_method(update_total_score, total_score, total_score * 2, 0.4).set_delay(1.5)
		tween.play()
		await tween.finished
	%FinishGame.visible = true
func _on_finish_game():
	%FinishGame.disabled = true
	AudioManager.stop_music(true, 1)
	GameManager.complete_minigame(wincon, total_score)

func update_total_score(value):
	%TotalScore.text = "Total Score: " + str(value).pad_zeros(3)
