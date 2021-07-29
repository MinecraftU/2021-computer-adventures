require "matrix" # matrix is installed when you install ruby, no need to use gem. docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html

class Tetromino # A tetromino is a tetris piece
  attr_reader :piece_data, :color_map, :screen
  
  def initialize(piece_data)
    raise ArgumentError unless piece_data.is_a? Matrix
    
    @color_map = {
      1=>[0, 255, 255, 1], # blue
      2=>[255, 255, 0, 1], # yellow
      3=>[128, 0, 128, 1], # purple
      4=>[0, 255, 0, 1], # green
      5=>[255, 0, 0, 1], # red
      6=>[0, 0, 255, 1], # dark blue
      7=>[255, 127, 0, 1] #orange
    } # Color scheme source: https://www.schemecolor.com/tetris-game-color-scheme.php
    
    # @screen = screen
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
          # screen.draw_box_s left_top, right_bottom, color
          Square.new(
            x: start_pos[0] + size*i, y: start_pos[1] + size*j,
            size: size,
            color: color,
            z: 10
          )
        end
      end
    end
  end
end

