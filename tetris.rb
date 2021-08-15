require "ruby2d"
require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
require_relative "tetromino"
require_relative "gameboard"
require_relative "game"

size = 40
gameboard_height = 20
gameboard_width = 10

game = Game.new(gameboard_height, gameboard_width)

set title: "Tetris"
set background: "white"
set width: size*gameboard_width
set height: size*gameboard_height

t = 1
update do
  begin
    if t % (10 / game.tetromino.fall_rate) == 0
      game.tetromino.moved = false
    end
  rescue
    game.tetromino.moved = false
  end

  if t % (60 / game.tetromino.fall_rate) == 0
    if game.tetromino.dead
      game.remove_filled_rows
      game.create_tetromino
    end
    game.draw([0, 0], size)
    game.tetromino.fall
    game.update_gameboard
    game.tetromino.reset_fall_rate
  end

  t += 1
end

on :key_held do |event|
  if event.key == "down"
    game.tetromino.moved = game.tetromino.move(event.key)
    game.update_gameboard
    game.draw([0, 0], size)
  end
end

on :key_down do |event|
  if ["left", "right", "up", "space"].include?(event.key)
    game.tetromino.moved = game.tetromino.move(event.key)
    game.update_gameboard
    game.draw([0, 0], size)
  end
end

show
