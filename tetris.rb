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
set height: size*gameboard_height+40

game_over = false
game_over_tick = -1
t = 1

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

update do
  unless started then next end
  if paused != 0
    if paused > 0
      paused -= 1
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
        game_over = true
        game_over_tick = t
      else
        paused = game.animate_filled_rows ? 10 : 0
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
    rescue ZeroDivisionError
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
  end

  t += 1
end

on :key_down do |event|
  if !game_over and started
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
  end
  if ["t"].include?(event.key) and !started
    start_text.remove
    logo_text.remove
    scoreboard.update
    started = true
  end
end

on :key_held do |event|
  if !game_over
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
