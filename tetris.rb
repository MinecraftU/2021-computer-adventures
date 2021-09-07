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
t = 1

paused = 0

update do
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

        leaderboard_contents = []
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
          # leaderboard file format: initials score level\ninitials score level...
          print "Initials: "
          initials = gets.chomp
          
          if leaderboard_contents.length != 0
            new_leaderboard_contents = leaderboard_contents[0...leaderboard_contents.length]
            leaderboard_contents.reverse.each do |spot|
              index = leaderboard_contents.index(spot)
              if spot[1] >= scoreboard.score
                new_leaderboard_contents.insert(index+1, [initials, scoreboard.score, scoreboard.level])
                puts spot[1]
                puts scoreboard.score
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
        end

        game_over = true
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
  end

  t += 1
end

on :key_down do |event|
  if !game_over
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
