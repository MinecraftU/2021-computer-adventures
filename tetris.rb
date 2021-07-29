require "ruby2d"
require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
require_relative "tetrominos"
require_relative "game"


game = Game.new

size = 50

set title: "Tetrominos"
set width: size*game.gameboard.width
set height: size*game.gameboard.height

t = 1
update do
    if t % 30 == 0
        game.draw([0, 0], size)
        game.tetromino.fall
        game.gameboard = game.tetromino.gameboard
        game.tetromino.moved = false
    end

    on :key_down do |event|
        if !game.tetromino.moved
            game.tetromino.moved = game.tetromino.move(event.key)
        end
    end

    t += 1
end

show
