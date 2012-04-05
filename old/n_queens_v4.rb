class Solver

  attr_accessor :board
  attr_accessor :iterations

  def initialize
    self.board = Board.new
    self.iterations = 0
  end

  def display_board
    puts self.board
    puts "Round #{self.iterations}: #{self.board.threatened_queens.count} threatened queens"
  end

  def solve(force_move = false)
    display_board
    return if self.board.threatened_queens.count == 0
    prev_threatened_queens = self.board.threatened_queens.count
    self.iterations += 1
    self.board.move_queens(force_move)
    if self.iterations % 10 == 1
      self.board.reset
    end
    self.solve(self.board.threatened_queens.count == prev_threatened_queens)
  end

end

class Board

  attr_accessor :size, :queens

  def initialize(size=10, queens = [])
    self.size = size
    self.queens = queens.empty? ? create_queens : queens.map{|q| q.clone}
  end

  def any_in?(coords)
    ! self.queens.select{|q| q.coords == coords}.empty?
  end

  def clone
    Board.new(self.size, self.queens)
  end

  def create_queens
    (0..self.size - 1).map{|i| Queen.new([i,0], self)}
  end

  def move_queens(force=false)
    self.queens.each{|q| q.move(force)}
    threatened = self.threatened_queens
    if ! threatened.empty? && force
      threatened.first.move(force)
    end
  end

  def reset
    (0..self.size - 1).map{|i| self.queens[i].move_to([i,0])}
  end

  def threatened_queens
    self.queens.select{|q| q.threatened?}
  end

  def to_s
    grid = "\n"
    (0..self.size - 1).each do |y|
      row = ""
      (0..self.size - 1).each do |x|
        square = self.queens.select{|q| q.coords == [x, y]}.empty? ? ". " : "Q "
        row << square
      end
      grid << row << "\n"
    end
    grid
  end

end

class Move

  attr_accessor :coords, :threatened_queens

  def initialize(coords, threatened_queens)
    self.coords = coords
    self.threatened_queens = threatened_queens
  end

end

class Queen

  attr_accessor :coords, :board

  def initialize(coords, board)
    self.coords = coords
    self.board = board
    @@queens ||= []; @@queens << self
    self
  end

  def allowable_squares
    allowable = []
    possible = self.possible_squares

    # Search right
    (self.x + 1..self.board.size - 1).each do |sq_x|
      next unless possible.include?([sq_x, self.y])
      break if self.board.any_in?([sq_x, self.y])
      allowable << [sq_x, self.y]
    end

    # Search left
    self.x.downto(0).each do |sq_x|
      next unless possible.include?([sq_x, self.y])
      break if self.board.any_in?([sq_x, self.y])
      allowable << [sq_x, self.y]
    end

    # Search up
    self.y.downto(0).each do |sq_y|
      next unless possible.include?([self.x, sq_y])
      break if self.board.any_in?([self.x, sq_y])
      allowable << [self.x, sq_y]
    end

    # Search down
    (self.y + 1..self.board.size - 1).each do |sq_y|
      next unless possible.include?([self.x, sq_y])
      break if self.board.any_in?([self.x, sq_y])
      allowable << [self.x, sq_y]
    end

    # Search up and right
    (self.x + 1..self.board.size - 1).each do |sq_x|
      self.y.downto(0).each do |sq_y|
        next unless possible.include?([sq_x, sq_y])
        break if self.board.any_in?([sq_x, sq_y])
        allowable << [sq_x, sq_y]
      end
    end

    # Search up and left
    self.x.downto(0).each do |sq_x|
      self.y.downto(0).each do |sq_y|
        next unless possible.include?([sq_x, sq_y])
        break if self.board.any_in?([sq_x, sq_y])
        allowable << [sq_x, sq_y]
      end
    end

    # Search down and right
    (self.x + 1..self.board.size - 1).each do |sq_x|
      (self.y + 1..self.board.size - 1).each do |sq_y|
        next unless possible.include?([sq_x, sq_y])
        break if self.board.any_in?([sq_x, sq_y])
        allowable << [sq_x, sq_y]
      end
    end

    # Search down and left
    self.x.downto(0).each do |sq_x|
      (self.y + 1..self.board.size - 1).each do |sq_y|
        next unless possible.include?([sq_x, sq_y])
        break if self.board.any_in?([sq_x, sq_y])
        allowable << [sq_x, sq_y]
      end
    end

    allowable.uniq

  end

  def optimal_moves
    optimal = []
    original_x = self.x
    original_y = self.y
    prev_threatened = self.board.threatened_queens.count
    self.allowable_squares.each do |coords|
      self.move_to(coords)
      threatened = self.board.threatened_queens.count
      if threatened <= prev_threatened
        optimal << Move.new([coords[0], coords[1]], threatened)
      end
      self.move_to([original_x, original_y])
    end
    if optimal.empty?
      false
    else
      optimal.sort{|a,b| a.threatened_queens <=> b.threatened_queens}.first.coords
    end
  end

  def possible_squares
    squares = []
    (0..self.board.size - 1).each do |sq_x|
      (0..self.board.size - 1).each do |sq_y|
        if (sq_x == self.x) || (sq_y == self.y) || ((sq_x - self.x).abs == (sq_y - self.y).abs)
          squares << [sq_x, sq_y]
        end
      end
    end
    squares - [[self.x, self.y]]
  end

  def move(force=false)
    return unless self.threatened? || force
    if optimal = self.optimal_moves
      self.move_to(optimal)
    elsif self.board.threatened_queens.count == 10 || force
      self.move_to_random_square
    else
      return
    end
  end

  def move_to_random_square
    destinations = allowable_squares
    self.coords = destinations[rand(destinations.count)]
    return self.board
  end

  def move_to(coords)
    self.coords = coords
    return self.board
  end

  def threatened?
    self.board.queens.select{|q| q != self}.each do |q|
      self.possible_squares.each do |sq_x, sq_y|
        return true if q.x == sq_x && q.y == sq_y
      end
    end
    false
  end

  def x
    self.coords[0]
  end

  def y
    self.coords[1]
  end

end