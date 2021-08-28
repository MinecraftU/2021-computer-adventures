class Game
  attr_accessor :tetromino

  def initialize(gameboard_height, gameboard_width, log, scoreboard)
    @log = log
    @scoreboard = scoreboard

    # tetrominos from https://user-images.githubusercontent.com/124208/127236186-733e6247-0824-4b2e-b464-552cd700bb65.png
    @tetromino_shapes = [
      Matrix[[1, 1, 1, 1]],
      Matrix[[6, 0, 0], [6, 6, 6]],
      Matrix[[0, 0, 7], [7, 7, 7]],
      Matrix[[2, 2], [2, 2]],
      Matrix[[0, 4, 4], [4, 4, 0]],
      Matrix[[0, 3, 0], [3, 3, 3]],
      Matrix[[5, 5, 0], [0, 5, 5]]
    ]
    
    @color_map = {
      1=>"aqua",
      2=>"yellow",
      3=>"purple",
      4=>"green",
      5=>"red",
      6=>"blue",
      7=>"orange"
    } # Color scheme source: https://www.schemecolor.com/tetris-game-color-scheme.php

    @gameboard = Gameboard.zero(gameboard_height, gameboard_width)
    @squares = Matrix.zero(gameboard_height, gameboard_width)

    create_tetromino()
  end

  def update_gameboard()
    @gameboard = tetromino.gameboard
  end

  def create_tetromino()
    @tetromino = Tetromino.new(@gameboard, @tetromino_shapes.sample, [0, 0])
    @gameboard = tetromino.put_tetromino(@gameboard, [0, 0], tetromino.piece_width, tetromino.piece_height)
  end

  def move_all_down(row)
    (row - 1).downto(-@gameboard.height).each do |i|
      (0...@gameboard.width).each do |j|
        @gameboard[i+1, j] = @gameboard[i, j] # set current position in line below current line to current position in the current line
        @gameboard[i, j] = 0 # set current position in current line to zero
      end
    end
  end

  def remove_filled_rows
    row_count = 0
    -1.downto(-@gameboard.height).each do |row|
      while !@gameboard.row(row).include?(0) # while row is full
        (0...@gameboard.width).each {|i| @gameboard[row, i] = 0} # set the line to all zeros
        unless row == -@gameboard.height # top row doesn't have anything above it, so no need to move stuff down.
          move_all_down(row)
        end
        @scoreboard.score_row
        row_count += 1
      end
    end
    if row_count == 4 
      @scoreboard.score_tetris
    end
  end

  def draw(start_pos, size) # size is the side length of a square
    begin
      (0...@gameboard.width).each do |i|
        (0...@gameboard.height).each do |j|
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
    rescue => error
      @log.debug error.message
    end
  end
end
