class Solver

  attr_accessor :board
  attr_accessor :iterations
  attr_accessor :max_step_size
  attr_accessor :last_step_size

  def initialize
    self.board = Board.new
    self.iterations = 0
    self.max_step_size = 100
  end

  def display_solution
    puts self.board
    puts "Iteration #{self.iterations}: #{self.board.threatened_queens} threatened queens"
  end

  def solved?
    self.board.threatened_queens == 0
  end

  def shuffle_board
    if solved?
      display_solution
    else
      puts self.board.to_s
      self.iterations += 1
      alt_1 = self.board.clone
      alt_2 = self.board.clone
      alt_1.shuffle_queens
      alt_2.shuffle_queens
      if alt_1.threatened_queens <= self.board.threatened_queens
        self.board = alt_1
      elsif alt_2.threatened_queens <= self.board.threatened_queens
        self.board = alt_2
      end
      self.shuffle_board
    end
  end

end

class Queen

  attr_accessor :x, :y

  def initialize(coords)
    self.coords = coords
  end

  def coords
    [self.x, self.y]
  end

  def coords=(coords)
    self.x = coords[0]
    self.y = coords[1]
  end

end

class Board

  attr_accessor :size
  attr_accessor :queens

  def initialize(size=8, queens = [])
    self.size = size
    self.queens = queens.empty? ? create_queens : queens.map{|q| q.clone}
  end

  def clone
    Board.new(self.size, self.queens)
  end

  def create_queens
    (1..self.size).map{|i| i = Queen.new([i,1])}
  end

  def occupied?(x,y)
    ! (self.queens && self.queens.select{|q| q.coords == [x,y]}.empty?)
  end

  def shuffle_queen(queen)
    queen.coords = unoccupied_square
  end

  def shuffle_queens
    shuffle_queen(self.queens[rand(self.queens.size)])
  end

  def threatened?(queen)
    self.queens.select{|q| q != queen}.each do |q|
      if (queen.x == q.x) || (queen.y == q.y) || ((queen.x - q.x).abs == (queen.y - q.y).abs)
        return true
      end
    end
    false
  end

  def threatened_queens
    self.queens.select{|q| threatened?(q)}.count
  end

  def to_s
    grid = "\n"
    (1..self.size).each do |y|
      row = []
      (1..self.size).each do |x|
        row << (self.occupied?(x,y) ? "Q" : ".")
      end
      grid << row * " " << "\n"
    end
    grid
  end

  def unoccupied_square
    x, y = rand(self.size) + 1, rand(self.size) + 1
    if occupied?(x,y)
      self.unoccupied_square
    else
      [x, y]
    end
  end

end

Solver.new.shuffle_board

