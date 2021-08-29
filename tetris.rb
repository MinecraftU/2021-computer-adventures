require "ruby2d"
require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
require_relative "tetromino"
require_relative "game"
require_relative "scoreboard"
require_relative "gameboard"
require "logger"

log = Logger.new('log.txt')

size = 40
gameboard_height = 20
gameboard_width = 10

scoreboard = Scoreboard.new(gameboard_width, gameboard_height)
game = Game.new(gameboard_height, gameboard_width, log, scoreboard)

set title: "Tetris"
set background: "white"
set width: size*gameboard_width
set height: size*gameboard_height+30

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
    game.draw([0, 30], size)
    game.tetromino.fall
    game.update_gameboard
    game.tetromino.reset_fall_rate
  end

  if game.tetromino.hard_dead
    game.remove_filled_rows
    game.create_tetromino
  end

  t += 1
end

on :key_down do |event|
  if ["left", "right", "up", "space"].include?(event.key)
    if !game.tetromino.moved
      if t % 15 == 0 || ["up", "space"].include?(event.key)
        game.tetromino.moved = game.tetromino.move(event.key)
        game.update_gameboard
        game.draw([0, 30], size)
      end
    end
  end
end

on :key_held do |event|
  if ["left", "right", "down"].include?(event.key)
    if !game.tetromino.moved
      if t % 5 == 0
        game.tetromino.moved = game.tetromino.move(event.key)
        game.update_gameboard
        game.draw([0, 30], size)
      end
    end
  end
end

show
