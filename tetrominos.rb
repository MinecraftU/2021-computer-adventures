require "rubygame"
require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html

class Tetromino # A tetromino is a tetris piece
    attr_reader :piece_data, :color_map, :screen

    def initialize(piece_data, screen)
        raise ArgumentError unless piece_data.is_a? Matrix
        
        @color_map = {1=>[0, 255, 255], 2=>[255, 255, 0], 3=>[128, 0, 128], 4=>[0, 255, 0], 5=>[255, 0, 0], 6=>[0, 0, 255], 7=>[255, 127, 0]} # Color scheme source: https://www.schemecolor.com/tetris-game-color-scheme.php

        @screen = screen
        @piece_data = piece_data
    end

    def draw(start_pos, size) # size is the side length of a square
        width = piece_data.row(0).to_a.length
        height = piece_data.column(0).to_a.length
        (0...width).each do |i|
            (0...height).each do |j|
                if piece_data[j, i] != 0
                    color = color_map[piece_data[j, i]]
                    left_top = [start_pos[0] + size*i, start_pos[1] + size*j]
                    right_bottom = [start_pos[0] + size*(i + 1), start_pos[1] + size*(j + 1)]
                    screen.draw_box_s left_top, right_bottom, color
                end
            end
        end
    end
end

Rubygame.init
screen = Rubygame::Screen.set_mode([1700, 150])
screen.title = "Tetrominos"
screen.fill [255, 255, 255]
screen.update
queue = Rubygame::EventQueue.new

# tetrominos from https://user-images.githubusercontent.com/124208/127236186-733e6247-0824-4b2e-b464-552cd700bb65.png
tetrominos = [
    Tetromino.new(Matrix[[1, 1, 1, 1]], screen),
    Tetromino.new(Matrix[[6, 0, 0], [6, 6, 6]], screen),
    Tetromino.new(Matrix[[0, 0, 7], [7, 7, 7]], screen),
    Tetromino.new(Matrix[[2, 2], [2, 2]], screen),
    Tetromino.new(Matrix[[0, 4, 4], [4, 4, 0]], screen),
    Tetromino.new(Matrix[[0, 3, 0], [3, 3, 3]], screen),
    Tetromino.new(Matrix[[5, 5, 0], [0, 5, 5]], screen)
]

sz = 50
running = true
while running
    queue.each do |event|
        case event
        when Rubygame::QuitEvent
            running = false
        when Rubygame::ActiveEvent
            (0...7).each do |i|
                tetrominos[i].draw([(i)*sz*5 + 10, 10], sz)
                screen.update
            end
        end
    end
end