class Board

  attr_accessor :size, :queens

  def initialize(size, queens = [])
    self.size = size
    self.queens = queens.empty? ? create_queens : queens.map{|q| q.clone}
  end

  def initial_state
    self.queens.map{|q| q.y}.uniq == [0]
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
      threatened.each{|q| q.move(force && rand(2) == 1)}
    end
  end

  def reset
    (0..self.size - 1).map{|i| self.queens[i].move_to([i,0])}
  end

  def squares
    return @squares if @squares
    @squares = []
    (0..self.size - 1).each do |sq_x|
      (0..self.size - 1).each do |sq_y|
        @squares << [sq_x, sq_y]
      end
    end
    @squares
  end

  def threatened_queens
    self.queens.select{|q| q.threatened?}
  end

  def to_s
    grid = "\n"
    (0..self.size - 1).each do |y|
      row = ""
      (0..self.size - 1).each do |x|
        square = self.queens.select{|q| q.coords == [x, y]}.empty? ? " . " : " Q "
        row << square
      end
      grid << row << "\n"
    end
    grid
  end

end
