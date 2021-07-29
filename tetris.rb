require "ruby2d"
require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
require_relative "tetrominos"
require_relative "game"

game = Game.new

set title: "Tetrominos"
set width: 500
set height: 1000

size = 50

t = 1
update do
  if t % 30 == 0
    game.draw([0, 0], size)
    game.tetromino.fall
    game.gameboard = game.tetromino.gameboard
  end
  t += 1
end

show
