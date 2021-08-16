class Gameboard < Matrix
  # matrix is installed when you install ruby, 
  # no need to use gem. 
  # docs: https://ruby-doc.org/stdlib-2.5.1/libdoc/matrix/rdoc/Matrix.html
  def height
    column(0).to_a.length
  end

  def width
    row(0).to_a.length
  end
end
