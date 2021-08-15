class Tetromino # A tetromino is a tetris piece
  attr_reader :piece_data, :width, :height, :pos, :gameboard, :dead, :fall_rate
  attr_accessor :moved

  def initialize(gameboard, piece_data, pos, gameboard_height, gameboard_width)
    raise ArgumentError unless piece_data.is_a? Matrix
    
    @gameboard_height = gameboard_height
    @gameboard_width = gameboard_width
    @gameboard = gameboard
    @pos = pos
    @piece_data = piece_data
    @width = piece_data.row(0).to_a.length
    @height = piece_data.column(0).to_a.length
    @moved = false
    @dead = false
    @fall_rate = 2 # ticks per second
    @accelerated = false
  end

  def put_tetromino(_gameboard=gameboard, _pos=pos, _width=width, _height=height, _piece_data=piece_data, clear=false)
    new_gameboard = Gameboard[*_gameboard] # changing new_gameboard changes _gameboard too, which we don't want.
    (0..._width).each do |i|
      (0..._height).each do |j|
        if _piece_data[j, i] != 0
          if clear
            if new_gameboard == Gameboard.empty(0, 0)
              new_gameboard = Gameboard.zero(20, 10)
            end
            new_gameboard[_pos[0]+j, _pos[1]+i] = 0
          else
            new_gameboard[_pos[0]+j, _pos[1]+i] = _piece_data[j, i]
          end
        end
      end
    end
    new_gameboard
  end

  def collision_detect(shadow_gameboard, shadow_pos, shadow_size, shadow_piece_data)
    shadowGameboardWithoutTetromino = put_tetromino(shadow_gameboard, shadow_pos, shadow_size[1], shadow_size[0], shadow_piece_data, clear=true)
    shadow_slice = shadowGameboardWithoutTetromino.minor((shadow_pos[0]...shadow_pos[0]+shadow_size[0]), (shadow_pos[1]...shadow_pos[1]+shadow_size[1]))

    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, piece_data, clear=true)
    real_slice = gameboardWithoutTetromino.minor((shadow_pos[0]...shadow_pos[0]+shadow_size[0]), (shadow_pos[1]...shadow_pos[1]+shadow_size[1]))

    shadow_slice != real_slice
  end

  def update(pos_index, inc, allow_die=true)
    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, piece_data, clear=true)
    shadow_pos = pos[0...pos.length]
    shadow_pos[pos_index] += inc
    shadow_gameboard = put_tetromino(gameboardWithoutTetromino, shadow_pos, width, height, piece_data)
    if collision_detect(shadow_gameboard, shadow_pos, [height, width], piece_data)
      if allow_die
        @dead = true
      end
    else
      @pos = shadow_pos
      @gameboard = shadow_gameboard
    end
  end

  def fall
    if pos[0] + height != @gameboard_height
      update(0, 1)
    else
      @dead = true
    end
  end

  def reset_fall_rate
    if @accelerated
      @fall_rate /= 5
    end
    @accelerated = false
  end

  def move(dir)
    case dir
    when "left"
      if pos[1] > 0
        update(1, -1, allow_die=false)
        return true
      end
    when "right"
      if pos[1] < @gameboard_width - width
        update(1, 1, allow_die=false)
        return true
      end
    when "up"
      return rotate
    when "down"
      if !@accelerated
        @fall_rate *= 5
        @accelerated = true
      end
      return @accelerated
    when "space"
      while !dead
        fall
      end
      return true
    end
    false
  end

  def rotate(allow_die=true)
    gameboardWithoutTetromino = put_tetromino(gameboard, pos, width, height, piece_data, clear=true)
    shadowPieceData = Gameboard[*(0...width).map {|i| piece_data.transpose.row(i).to_a.reverse}] # Matrix.transpose almost rotates, but we need to reverse each row. Asterix to prevent everything to be nested in one []
    shadow_width = shadowPieceData.row(0).to_a.length
    shadow_height = shadowPieceData.column(0).to_a.length
    begin
      shadow_gameboard = put_tetromino(gameboardWithoutTetromino, pos, shadow_width, shadow_height, shadowPieceData)
      if collision_detect(shadow_gameboard, pos, [shadow_height, shadow_width], shadowPieceData)
        if allow_die
          @dead = true
        end
      else
        @width = shadow_width
        @height = shadow_height
        @piece_data = shadowPieceData
        @gameboard = shadow_gameboard
      end
    rescue
      return false
    end
    true
  end
end
