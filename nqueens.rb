require 'optparse'
require './board'
require './move'
require './queen'
require './solver'

board_size = 8
OptionParser.new{ |opts| opts.on('-s', '--size SIZE', 'Board Size') { |v| board_size = v.to_i }}.parse!
Solver.new(board_size).solve
