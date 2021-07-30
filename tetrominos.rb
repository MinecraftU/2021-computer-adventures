require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html

class Tetromino # A tetromino is a tetris piece
  attr_reader :piece_data, :color_map, :width, :height, :gameboard
  attr_accessor :pos, :moved

  def initialize(gameboard, piece_data, pos)
    raise ArgumentError unless piece_data.is_a? Matrix
    
    @gameboard = gameboard
    @pos = pos
    @piece_data = piece_data
    @width = piece_data.row(0).to_a.length
    @height = piece_data.column(0).to_a.length
    @moved = false
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

  def update(pos_index, inc)
    put_tetromino(clear=true)
    pos[pos_index] += inc
    put_tetromino
  end

  def fall
    if pos[0] + height != gameboard.height
      update(0, 1)
    end
  end

  def move(dir)
    case dir
    when "left"
      if pos[1] > 0
        update(1, -1)
        return true
      end
    when "right"
      if pos[1] < gameboard.width - width
        update(1, 1)
        return true
      end
    when "up"
      rotate
      return true
    else
      return false
    end
    false
  end

  def rotate
    height % 2 == 0 ? update(0, -(height / 2)) : update(0, -(height / 2 - 1))
    put_tetromino(clear=true)
    @piece_data = Matrix[*(0...width).map {|i| piece_data.transpose.row(i).to_a.reverse}] # Matrix.transpose almost rotates, but we need to reverse each row. Asterix to prevent everything to be nested in one []
    @width = piece_data.row(0).to_a.length
    @height = piece_data.column(0).to_a.length
    put_tetromino
  end
end
