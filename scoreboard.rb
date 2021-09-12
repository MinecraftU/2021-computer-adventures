class Scoreboard
  attr_reader :level

  def initialize(gameboard_width, gameboard_height)
    @score = 0
    @lines_cleared = 0
    @level = 1
    # x_pos = Window.width / 2
    @text = Text.new(
      '',
      x: 0, y: 0,
      size: 27,
      color: 'black',
      z: 10
    )
    @boom_text = Text.new(
      '',
      x: 290, y: 0,
      size: 27,
      color: 'black',
      z: 10
    )
    @prev_tetris = false
  end

  def reset_boom_text
    @boom_text.text = ""
  end

  def update
    @level = @lines_cleared/5 + 1 # Update level
    @text.text = "Level: #{@level} Score: #{@score}" # Update text
  end

  def score_acceleration
    @score += 1*level
    update
  end

  def score_hard_drop(dis)
    @score += 2*dis*level
    update
  end

  def score_row
    @score += 100*level
    @lines_cleared += 1
    update
    @prev_tetris = false
  end

  def score_tetris
    @score += 800*level
    if @prev_tetris
      @score += 200*level
    end
    @lines_cleared += 8
    update
    @boom_text.text = "TETRIS!"
    @prev_tetris = true
  end
end