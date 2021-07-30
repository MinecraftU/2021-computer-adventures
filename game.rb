class Game
  attr_reader :tetromino_shapes, :color_map, :size
  attr_accessor :gameboard, :tetromino

  def initialize
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

    height = 20
    width = 10
    @gameboard = Matrix.zero(height, width)
    gameboard.define_singleton_method(:height) {height}
    gameboard.define_singleton_method(:width) {width}
    @size = 50

    pos = [0, 0]
    @tetromino = Tetromino.new(gameboard, tetromino_shapes.sample, [0, 0])
    tetromino.put_tetromino
  end

  def draw(start_pos, size) # size is the side length of a square
    (0...gameboard.width).each do |i|
      (0...gameboard.height).each do |j|
        # the color is white if the gameboard space is empty, otherwise the color is the matching color on the color_map hash.
        color = gameboard[j, i] == 0 ? "white" : color_map[gameboard[j, i]] 
        # draws a square starting at point (x, y) with side length size and color color. z is the layer (the higher z is, the higher on the layers the shape is)
        Square.new(
          x: start_pos[0] + size*i, y: start_pos[1] + size*j,
          size: size,
          color: color,
          z: 10
        )
      end
    end
  end
end
