class Move

  attr_accessor :coords, :threatened_queens

  def initialize(coords, threatened_queens)
    self.coords = coords
    self.threatened_queens = threatened_queens
  end

end