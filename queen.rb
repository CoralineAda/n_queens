class Queen

  attr_accessor :coords, :board

  # :horizontal, :vertical, :diagonal
  SEARCH_DIRECTIONS = [:vertical]

  def initialize(coords, board)
    self.coords = coords
    self.board = board
    @@queens ||= []; @@queens << self
    self
  end

  def allowable_squares
    allowable = []
    possible = self.possible_squares

    if SEARCH_DIRECTIONS.include?(:horizontal)

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

    end

    if SEARCH_DIRECTIONS.include?(:vertical)

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

    end

    if SEARCH_DIRECTIONS.include?(:diagonal)

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

    end

    allowable.uniq

  end

  def move(force=false)
    return unless self.threatened? || force
    if optimal = self.optimal_move
      self.move_to(optimal)
    elsif self.board.threatened_queens.count == 10 || force
      self.move_to_random_square
    else
      return
    end
  end

  def move_to(coords)
    self.coords = coords
    return self.board
  end

  def move_to_random_square
    destinations = allowable_squares
    self.coords = destinations[rand(destinations.count)]
    return self.board
  end

  def optimal_move
    if self.use_optimal_move_strategy
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
    else
      self.allowable_squares[rand(self.allowable_squares.count)]
    end
  end

  def use_optimal_move_strategy
    true #self.board.size <= 10
  end

  def possible_squares
    squares = []
    self.board.squares.each do |sq_x, sq_y|
      if (sq_x == self.x) || (sq_y == self.y) || ((sq_x - self.x).abs == (sq_y - self.y).abs)
        squares << [sq_x, sq_y]
      end
    end
    squares - [[self.x, self.y]]
  end

  def threatened?
    self.possible_squares.each do |coords|
      return true if self.board.queens.select{|q| q.coords == coords}.count > 0
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