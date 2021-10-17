# "build" file hand-generated on 2021-10-17

# core ruby requires

require "ruby2d"
require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
require "logger"


# tetris.rb

log = Logger.new('log.txt')

size = 40
gameboard_height = 20
gameboard_width = 10
# For leaderboard stuff
initials = ""
on_leaderboard = false
leaderboard_written = false
text = []
leaderboard_contents = []

scoreboard = Scoreboard.new(gameboard_width, gameboard_height)
game = Game.new(gameboard_height, gameboard_width, log, scoreboard)

set title: "Tetris"
set background: "white"
set width: size*gameboard_width
set height: size*gameboard_height+40

game_over = false
t = 1

log = Logger.new('log.txt')
paused = 0
started = false
logo_text = Text.new(
  "TETRIS",
  x: 105,
  y: size*gameboard_height / 2 - 350,
  font: 'RussoOne-Regular.ttf',
  size: 50,
  color: 'red',
  z: 100
)
start_text = Text.new(
  "Press T to Start",
  x: 85,
  y: size*gameboard_height / 2 - 150,
  font: 'RussoOne-Regular.ttf',
  size: 30,
  color: 'blue',
  z: 100
)

def display_leaderboard(sz, gameboard_h)
  leaderboard_text_lines = ["Leaderboard"]
  leaderboard_contents = File.read("leaderboard.txt").split("\n")
  highest_score_length = leaderboard_contents[0].split[1].length
  leaderboard_contents = leaderboard_contents.map {|line| 
    line.split[0] + " "*6 + 
    line.split[1].ljust([highest_score_length, 5].max) + " " + 
    line.split[2]
  }
  leaderboard_contents.insert(0, "Initials" + " " + "Score".ljust(highest_score_length) + " " + "Level")
  leaderboard_text_lines += leaderboard_contents
  leaderboard_text = []
  (0...leaderboard_text_lines.length).each do |line_num|
      leaderboard_text << Text.new(
      leaderboard_text_lines[line_num],
      x: 20,
      y: sz*gameboard_h / 2 + 150 + 28*line_num,
      font: 'AzeretMono-Light.ttf',
      size: 28,
      color: 'black',
      z: 100
    )
  end
  leaderboard_text
end
leaderboard_text = display_leaderboard(size, gameboard_height)

update do
  unless started then next end
  if paused != 0
    if paused > 0
      paused = game.animate_filled_rows(paused - 1)
    end
    next
  end
  if !game_over
    if game.tetromino.hard_dead
      if game.tetromino.pos[0] == 0 # if the tetromino died when still at highest y level
        set background: "random"
        Text.new(
          "GAME OVER",
          x: 50,
          y: size*gameboard_height / 2,
          size: 50,
          color: 'black',
          z: 100
        )

        unless File.exist?("leaderboard.txt") then
          File.new "leaderboard.txt","w+"
        end
        File.read("leaderboard.txt").split("\n").each do |line|
          line_contents = []
          line.split.each_with_index do |item, i|
            if i == 0
              line_contents << item
            else
              line_contents << item.to_i
            end
          end
          leaderboard_contents << line_contents
        end

        begin
          last_spot = leaderboard_contents[-1]
        rescue => IndexError
          last_spot = false
        end

        if (leaderboard_contents.length < 5) || last_spot[1] < scoreboard.score
          text << Text.new("Please press 3 letters or dashes as your", y:gameboard_height*size/3, z:1000)
          text << Text.new(" initials. This is for the leaderboard.", y:gameboard_height*size/3+15, z:1000)
          on_leaderboard = true
        end

        game_over = true
      else
        paused = game.animate_filled_rows(paused)
        if paused == 0
          game.remove_filled_rows
          game.create_tetromino
        end
      end
    end

    begin
      if t % game.tetromino.fall_rate/6 == 0
        game.tetromino.moved = false
      end
    rescue => ZeroDivisionError
      game.tetromino.moved = false
    end

    if t % (game.tetromino.fall_rate * 10) == 0
      scoreboard.reset_boom_text
    end

    if t % game.tetromino.fall_rate == 0
      game.draw([0, 40], size)
      game.tetromino.fall
      game.update_gameboard
      game.update_ghost_tetromino
      game.tetromino.reset_fall_rate
      game.tetromino.update_fall_rate
    end

  else
    if t % 20 == 0
      set background: "random"
    end

    if on_leaderboard == true && initials.length == 3 && leaderboard_written == false
      # leaderboard file format: initials score level\ninitials score level...
      initials = initials.upcase()
      text.each {|i| i.remove}
      
      if leaderboard_contents.length != 0
        new_leaderboard_contents = leaderboard_contents[0...leaderboard_contents.length]
        leaderboard_contents.reverse.each do |spot|
          index = leaderboard_contents.index(spot)
          if spot[1] >= scoreboard.score
            new_leaderboard_contents.insert(index+1, [initials, scoreboard.score, scoreboard.level])
            break
          elsif index == 0
            new_leaderboard_contents.unshift([initials, scoreboard.score, scoreboard.level])
            break
          end
        end
        leaderboard_contents = new_leaderboard_contents
      else
        leaderboard_contents = [[initials, scoreboard.score, scoreboard.level]]
      end

      leaderboard_contents = leaderboard_contents[0...5]

      new_leaderboard_text = (leaderboard_contents.map {|spot| spot.join(" ")}).join("\n")
      File.write("leaderboard.txt", new_leaderboard_text)

      leaderboard_written = true
    else
      not_on_leaderboard = true
    end

    if leaderboard_written || not_on_leaderboard
      display_leaderboard(size, gameboard_height)
    end
  end

  t += 1
end

on :key_down do |event|
  if !game_over && started
    if ["left", "right", "up", "space"].include?(event.key)
      if (!game.tetromino.moved && t % 15 == 0) || ["up", "space"].include?(event.key)
        game.tetromino.moved = game.tetromino.move(event.key)
        game.update_gameboard
        game.update_ghost_tetromino
        game.draw([0, 40], size)
      end
    end
    if ["p"].include?(event.key)
      if paused > -1
        paused = -1
      elsif paused == -1
        paused = 0
      end
    end
  else
    if "qwertyuiopasdfghjklzxcvbnm-".include?(event.key) && initials.length != 3 && game_over
      initials += event.key
    end
  end
  if ["t"].include?(event.key) && !started
    start_text.remove
    logo_text.remove
    leaderboard_text.each {|text| text.remove}
    scoreboard.update
    started = true
  end
end

on :key_held do |event|
  if !game_over && started
    if ["left", "right", "down"].include?(event.key)
      if t % 5 == 0
        game.tetromino.moved = game.tetromino.move(event.key)
        game.update_gameboard
        game.update_ghost_tetromino
        game.draw([0, 40], size)
      end
    end
  end
end

show


# tetromino.rb

class Tetromino # A tetromino is a tetris piece
  attr_reader :piece_data, :width, :height, :pos, :gameboard, :soft_dead, :hard_dead, :fall_rate
  attr_accessor :moved

  def initialize(gameboard, piece_data, pos, gameboard_height, gameboard_width, scoreboard)
    raise ArgumentError unless piece_data.is_a? Matrix
    
    @scoreboard = scoreboard
    @gameboard_height = gameboard_height
    @gameboard_width = gameboard_width
    @gameboard = gameboard
    @pos = pos
    @piece_data = piece_data
    @width = piece_data.row(0).to_a.length
    @height = piece_data.column(0).to_a.length
    @moved = false
    @soft_dead = false
    @hard_dead = false
    @fall_rate = 30 # will fall every @fall_rate/60 seconds
    @accelerated = false
  end

  def eval_dead(collided, tmp=false)
    if collided
      if soft_dead
        @hard_dead = true
      else
        @soft_dead = true
      end
    elsif soft_dead
      @soft_dead = false
    end
  end

  def put_tetromino(_gameboard=gameboard, _pos=pos, _width=width, _height=height, _piece_data=piece_data, clear=false)
    new_gameboard = Gameboard[*_gameboard] # changing new_gameboard changes _gameboard too, which we don't want.
    (0..._width).each do |i|
      (0..._height).each do |j|
        if _piece_data[j, i] != 0
          if clear
            if new_gameboard == Gameboard.empty(0, 0)
              new_gameboard = Gameboard.zero(20, 10)
            end
            new_gameboard[_pos[0]+j, _pos[1]+i] = 0
          else
            new_gameboard[_pos[0]+j, _pos[1]+i] = _piece_data[j, i]
          end
        end
      end
    end
    new_gameboard
  end

  def collision_detect(shadow_gameboard, shadow_pos, shadow_size, shadow_piece_data)
    shadowGameboardWithoutTetromino = put_tetromino(shadow_gameboard, shadow_pos, shadow_size[1], shadow_size[0], shadow_piece_data, clear=true)
    shadow_slice = shadowGameboardWithoutTetromino.minor((shadow_pos[0]...shadow_pos[0]+shadow_size[0]), (shadow_pos[1]...shadow_pos[1]+shadow_size[1]))

    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, piece_data, clear=true)
    real_slice = gameboardWithoutTetromino.minor((shadow_pos[0]...shadow_pos[0]+shadow_size[0]), (shadow_pos[1]...shadow_pos[1]+shadow_size[1]))

    shadow_slice != real_slice
  end

  def update(pos_index, inc, allow_die=true)
    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, piece_data, clear=true)
    shadow_pos = pos[0...pos.length]
    shadow_pos[pos_index] += inc
    shadow_gameboard = put_tetromino(gameboardWithoutTetromino, shadow_pos, width, height, piece_data)
    collided = collision_detect(shadow_gameboard, shadow_pos, [height, width], piece_data)
    if allow_die
      eval_dead(collided)
    end
    if (!soft_dead || pos_index == 1) && !collided
      @pos = shadow_pos
      @gameboard = shadow_gameboard
    end
  end

  def fall
    if pos[0] + height < @gameboard_height
      update(0, 1)
    else
      eval_dead(true, true)
    end
  end

  def reset_fall_rate
    if @accelerated
      @fall_rate *= 8
    end
    @accelerated = false
  end

  def update_fall_rate
    if @fall_rate != 1
      @fall_rate = 32 - @scoreboard.level
    end
  end

  def hard_drop
    while !hard_dead
      fall
    end
  end
  
  def move(dir)
    case dir
    when "left"
      if pos[1] > 0
        update(1, -1, allow_die=false)
        return true
      end
    when "right"
      if pos[1] < @gameboard_width - width
        update(1, 1, allow_die=false)
        return true
      end
    when "up"
      return rotate
    when "down"
      if !@accelerated && !hard_dead # needs && !hard_dead so no extra score is added in the interval between tetromino dying and new tetromino spawning
        @scoreboard.score_acceleration
        @fall_rate /= 8 
        @accelerated = true
      end
      return @accelerated
    when "space"
      start_y = pos[0]
      hard_drop
      end_y = pos[0]
      @scoreboard.score_hard_drop(end_y - start_y)
      return true
    end
    false
  end

  def rotate()
    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, piece_data, clear=true)
    shadowPieceData = Matrix[*(0...width).map {|i| piece_data.transpose.row(i).to_a.reverse}] # Matrix.transpose almost rotates, but we need to reverse each row. Asterix to prevent everything to be nested in one []
    shadow_width = shadowPieceData.row(0).to_a.length
    shadow_height = shadowPieceData.column(0).to_a.length
    begin
      shadow_gameboard = put_tetromino(gameboardWithoutTetromino, pos, shadow_width, shadow_height, shadowPieceData)
      if collision_detect(shadow_gameboard, pos, [shadow_height, shadow_width], shadowPieceData)
        return false
      else
        @width = shadow_width
        @height = shadow_height
        @piece_data = shadowPieceData
        @gameboard = shadow_gameboard
      end
    rescue
      return false
    end
    true
  end
end


# game.rb

class Game
  attr_accessor :tetromino, :gameboard

  def initialize(gameboard_height, gameboard_width, log, scoreboard)
    @log = log
    @scoreboard = scoreboard

    # tetrominos from https://user-images.githubusercontent.com/124208/127236186-733e6247-0824-4b2e-b464-552cd700bb65.png
    @tetromino_shapes = [
      Matrix[[1, 1, 1, 1]],
      Matrix[[2, 2], [2, 2]],
      Matrix[[0, 3, 0], [3, 3, 3]],
      Matrix[[0, 4, 4], [4, 4, 0]],
      Matrix[[5, 5, 0], [0, 5, 5]],
      Matrix[[6, 0, 0], [6, 6, 6]],
      Matrix[[0, 0, 7], [7, 7, 7]]
    ]
    
    @color_map = {
      1=>"aqua",
      2=>"yellow",
      3=>"purple",
      4=>"green",
      5=>"red",
      6=>"blue",
      7=>"orange",
      8=>"#C9C9C9", # light grey
      9=>"#f9d35a", # yellow/gold
      10=>"#fff2c8" # light yellow
    } # Color scheme source: https://www.schemecolor.com/tetris-game-color-scheme.php

    @gameboard_height = gameboard_height
    @gameboard_width = gameboard_width
    @gameboard = Gameboard.zero(gameboard_height, gameboard_width)
    @squares = Gameboard.zero(gameboard_height, gameboard_width)

    @bag = []
    create_tetromino()
  end

  def update_gameboard()
    @gameboard = tetromino.gameboard
  end

  def create_tetromino()
    if @bag.length == 0
      @bag = @tetromino_shapes.shuffle
    end
    piece_data = @bag.pop

    @color_num = @tetromino_shapes.index(piece_data)+1
    pos = [0, @gameboard_width / 2 - piece_data.row(0).to_a.length / 2]
    @tetromino = Tetromino.new(@gameboard, piece_data, pos, @gameboard_height, @gameboard_width, @scoreboard)
    @gameboard = tetromino.put_tetromino(@gameboard, pos, tetromino.width, tetromino.height)
  end

  def update_ghost_tetromino
    ghost_piece_data = Matrix[*tetromino.piece_data]
    (0...ghost_piece_data.row(0).to_a.length).each do |i|
      (0...ghost_piece_data.column(0).to_a.length).each do |j|
        if ghost_piece_data[j, i] != 0
          ghost_piece_data[j, i] = 8
        end
      end
    end
    ghost_tetromino = Tetromino.new(@gameboard, ghost_piece_data, tetromino.pos, @gameboard_height, @gameboard_width, @scoreboard)
    ghost_tetromino.hard_drop
    @gameboard = ghost_tetromino.put_tetromino(@gameboard, ghost_tetromino.pos, ghost_tetromino.width, ghost_tetromino.height)

    (0...tetromino.width).each do |i|
      (0...tetromino.height).each do |j|
        if tetromino.piece_data[j, i] != 0
          gameboard[tetromino.pos[0]+j, tetromino.pos[1]+i] = @color_num
        end
      end
    end
  end

  def move_all_down(row)
    (row - 1).downto(-@gameboard_height).each do |i|
      (0...@gameboard_width).each do |j|
        @gameboard[i+1, j] = @gameboard[i, j] # set current position in line below current line to current position in the current line
        @gameboard[i, j] = 0 # set current position in current line to zero
      end
    end
  end

  def animate_filled_rows(paused_for)
    pause_length = paused_for
    if paused_for == 0
      -1.downto(-@gameboard.height).each do |row|
        while !@gameboard.row(row).include?(0) && !@gameboard.row(row).include?(9) && !@gameboard.row(row).include?(10) # row is full
          (0...@gameboard_width).each {|i| @gameboard[row, i] = 9}
          pause_length = 16
        end
      end
    elsif paused_for < 8
      -1.downto(-@gameboard.height).each do |row|
        while @gameboard.row(row).include?(9) # row is full
          (0...@gameboard_width).each {|i| @gameboard[row, i] = 10}
        end
      end
    end
    draw([0, 40], 40)
    return pause_length
  end

  def remove_filled_rows
    row_count = 0
    -1.downto(-@gameboard.height).each do |row|
      while @gameboard.row(row).include?(10) # row is full
        (0...@gameboard_width).each {|i| @gameboard[row, i] = 0} # set the line to all zeros
        unless row == -@gameboard_height # top row doesn't have anything above it, so no need to move stuff down.
          move_all_down(row)
        end
        row_count += 1
      end
    end
    if row_count == 4 
      @scoreboard.score_tetris
    else
      row_count.times do
        @scoreboard.score_row
      end
    end
  end

  def draw(start_pos, size) # size is the side length of a square
    (0...@gameboard_width).each do |i|
      (0...@gameboard_height).each do |j|
        if @squares[j, i] != 0
          @squares[j, i].remove
        end
        if @gameboard[j, i] != 0
          color = @color_map[@gameboard[j, i]] 
          # draws a square starting at point (x, y) with side length size and color color. z is the layer (the higher z is, the higher on the layers the shape is)
          @squares[j, i] = Square.new(
            x: start_pos[0] + size*i, y: start_pos[1] + size*j,
            size: size,
            color: color,
            z: 10
          )
        end
      end
    end
  end
end


# scoreboard.rb

class Scoreboard
  attr_reader :level, :score

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


# gameboard.rb

class Gameboard < Matrix
  # matrix is installed when you install ruby, 
  # no need to use gem. 
  # docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
  def height
    column(0).to_a.length
  end

  def width
    row(0).to_a.length
  end
end

