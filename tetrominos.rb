require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html

class Tetromino # A tetromino is a tetris piece
  attr_reader :piece_data, :color_map, :width, :height, :dead, :gameboard_height, :gameboard_width
  attr_accessor :pos, :moved, :gameboard  

  def initialize(gameboard, piece_data, pos)
    raise ArgumentError unless piece_data.is_a? Matrix
    
    @gameboard_width = 10
    @gameboard_height = 20
    @gameboard = gameboard
    @pos = pos
    @piece_data = piece_data
    @width = piece_data.row(0).to_a.length
    @height = piece_data.column(0).to_a.length
    @moved = false
    @dead = false
  end

  def put_tetromino(_gameboard=gameboard, _pos=pos, _width=width, _height=height, clear=false)
    new_gameboard = Matrix[*_gameboard] # changing new_gameboard changes _gameboard too, which we don't want.
    (0..._width).each do |i|
      (0..._height).each do |j|
        if piece_data[j, i] != 0
          if clear
            if new_gameboard == Matrix.empty(0, 0)
              new_gameboard = Matrix.zero(20, 10)
            end
            new_gameboard[_pos[0]+j, _pos[1]+i] = 0
          else
            new_gameboard[_pos[0]+j, _pos[1]+i] = piece_data[j, i]
          end
        end
      end
    end
    new_gameboard
  end

  def collision_detect(shadow_gameboard, shadow_pos, shadow_size, shadow_piece_data)
    shadowGameboardWithoutTetromino = put_tetromino(shadow_gameboard, shadow_pos, shadow_size[1], shadow_size[0], clear=true)
    shadow_slice = shadowGameboardWithoutTetromino.minor((shadow_pos[0]...shadow_pos[0]+shadow_size[0]), (shadow_pos[1]...shadow_pos[1]+shadow_size[1]))

    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, clear=true)
    real_slice = gameboardWithoutTetromino.minor((shadow_pos[0]...shadow_pos[0]+shadow_size[0]), (shadow_pos[1]...shadow_pos[1]+shadow_size[1]))

    shadow_slice != real_slice
  end

  def update(pos_index, inc, allow_die=true)
    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, clear=true)
    shadow_pos = pos[0...pos.length]
    shadow_pos[pos_index] += inc
    shadow_gameboard = put_tetromino(gameboardWithoutTetromino, shadow_pos, width, height)
    if collision_detect(shadow_gameboard, shadow_pos, [height, width], piece_data)
      if allow_die
        @dead = true
      end
    else
      @gameboard = put_tetromino(gameboard, pos, width, height, clear=true)
      pos[pos_index] += inc
      @gameboard = put_tetromino(gameboard, pos, width, height)
    end
  end

  def fall
    if pos[0] + height != gameboard_height
      update(0, 1)
    else
      @dead = true
    end
  end

  def move(dir)
    case dir
    when "left"
      if pos[1] > 0
        update(1, -1, allow_die=false)
        return true
      end
    when "right"
      if pos[1] < gameboard_width - width
        update(1, 1, allow_die=false)
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
    @gameboard = put_tetromino(gameboard, pos, width, height, clear=true)
    @piece_data = Matrix[*(0...width).map {|i| piece_data.transpose.row(i).to_a.reverse}] # Matrix.transpose almost rotates, but we need to reverse each row. Asterix to prevent everything to be nested in one []
    @width = piece_data.row(0).to_a.length
    @height = piece_data.column(0).to_a.length
    @gameboard = put_tetromino(gameboard, pos, width, height)
  end
end
