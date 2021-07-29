require "ruby2d"
require "matrix"

class Tetromino # A tetromino is a tetris piece
    attr_reader :piece_data, :color_map, :width, :height, :gameboard
    attr_accessor :pos

    def initialize(gameboard, piece_data, pos)
        raise ArgumentError unless piece_data.is_a? Matrix
        
        @gameboard = gameboard
        @pos = pos
        @piece_data = piece_data
        @width = piece_data.row(0).to_a.length
        @height = piece_data.column(0).to_a.length
        @x=0
    end

    def put_tetromino(clear=false)
        (0...width).each do |i|
            (0...height).each do |j|
                if clear
                    gameboard[pos[0]+j, pos[1]+i] = 0
                else
                    gameboard[pos[0]+j, pos[1]+i] = piece_data[j, i]
                end
            end
        end
    end

    def move
        if pos[0] + height != gameboard.height
            put_tetromino(clear=true)
            pos[0] += 1
            put_tetromino
        end
    end

end

