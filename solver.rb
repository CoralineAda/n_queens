class Solver

  attr_accessor :board
  attr_accessor :iterations
  attr_accessor :permutations

  def initialize(board_size=8)
    self.board = Board.new(board_size)
    self.iterations = 0
    self.permutations = []
  end

  def create_permutation
    clone = self.board.clone
    clone.move_queens(true)
    clone
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
    mutants = []
    if force_move || self.board.initial_state
      self.board.move_queens(true)
    else
      prev_threatened_queens.times{mutants << create_permutation}
      mutants = mutants - self.permutations
      sorted = mutants.sort{|a,b| a.threatened_queens.count <=> b.threatened_queens.count}
      best = sorted.empty? ? [] : sorted.min{|b| b.threatened_queens.count}.threatened_queens.count
      optimal = sorted.select{|b| b.threatened_queens.count == best }
      selection = optimal.first
      if selection && selection.threatened_queens.count < prev_threatened_queens
        self.board = selection
      else
        self.board.move_queens(true)
      end
    end
    self.permutations << self.board
    self.permutations.uniq!
    self.solve(self.board.threatened_queens.count == prev_threatened_queens)
  end

end
