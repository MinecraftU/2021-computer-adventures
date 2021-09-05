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
      8=>"#C9C9C9" # light grey
    } # Color scheme source: https://www.schemecolor.com/tetris-game-color-scheme.php

    @gameboard_height = gameboard_height
    @gameboard_width = gameboard_width
    @gameboard = Gameboard.zero(gameboard_height, gameboard_width)
    @squares = Gameboard.zero(gameboard_height, gameboard_width)

    create_tetromino()
  end

  def update_gameboard()
    @gameboard = tetromino.gameboard
  end

  def create_tetromino()
    piece_data = @tetromino_shapes.sample
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

  def remove_filled_rows
    row_count = 0
    -1.downto(-@gameboard.height).each do |row|
      while !@gameboard.row(row).include?(0) # while row is full
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
    return row_count*10 # give a slight pause relative to how many rows were cleared
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
