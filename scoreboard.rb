class Scoreboard
  def initialize(gameboard_width, gameboard_height)
    @score = 0
    # x_pos = Window.width / 2
    @text = Text.new(
      'Score: 0',
      x: 0, y: 0,
      size: 30,
      color: 'black',
      z: 10
    )
    @boom_text = Text.new(
      '',
      x: 200, y: 0,
      size: 30,
      color: 'black',
      z: 10
    )
  end

  def reset_boom_text
    @boom_text.text = ""
  end

  def update_score_text
    @text.text = "Score: #{@score}"
  end

  def score_acceleration
    @score += 1
    update_score_text
  end

  def score_hard_drop(dis)
    @score += 2*dis
    update_score_text
  end

  def score_row
    @score += 100
    update_score_text
  end

  def score_tetris
    @score += 400
    update_score_text
    @boom_text.text = "TETRIS!"
  end
end