require "rubygame"
require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
require_relative "tetrominos"

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