class Scoreboard
  def initialize(gameboard_width, gameboard_height)
    @score = 0
    # x_pos = Window.width / 2
    @text = Text.new(
      'Score: 0',
      x: 0, y: 0,
      size: 20,
      color: 'black',
      z: 10
    )
    @boom_text = Text.new(
      '',
      x: 200, y: 0,
      size: 20,
      color: 'black',
      z: 10
    )
  end

  def score_row
    @score += 1
    @text.text = "Score #{@score}"
    @boom_text.text = ""
  end

  def score_tetris
    @score += 4
    @text.text = "Score #{@score}"
    @boom_text.text = "TETRIS!"
  end
end