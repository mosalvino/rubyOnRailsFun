class GameState < ApplicationRecord
	after_initialize :init_board

	def init_board
		self.board ||= '---------'
		self.current_player ||= 'X'
		self.status ||= 'ongoing'
	end

	def board_array
		self.board.chars.each_slice(3).to_a
	end

	def play_move(position)
		return false unless self.status == 'ongoing' && self.board[position] == '-'
		self.board[position] = self.current_player
		self.current_player = self.current_player == 'X' ? 'O' : 'X'
		self.status = check_status
		save
	end

	def check_status
		lines = [
			[0,1,2], [3,4,5], [6,7,8], # rows
			[0,3,6], [1,4,7], [2,5,8], # columns
			[0,4,8], [2,4,6]           # diagonals
		]
		lines.each do |line|
			values = line.map { |i| self.board[i] }
			return "#{values[0]} wins" if values.uniq.length == 1 && values[0] != '-'
		end
		return 'draw' unless self.board.include?('-')
		'ongoing'
	end

	# Returns the best move for the CPU using minimax
	def best_move(cpu_player = 'O')
		moves = available_moves
		best_score = -Float::INFINITY
		move = nil
		moves.each do |pos|
			board_copy = self.board.dup
			board_copy[pos] = cpu_player
			score = minimax(board_copy, false, cpu_player, cpu_player == 'X' ? 'O' : 'X')
			if score > best_score
				best_score = score
				move = pos
			end
		end
		move
	end

	# Minimax algorithm implementation
	def minimax(board, is_maximizing, cpu_player, human_player)
		result = static_check_status(board)
		return 1 if result == "#{cpu_player} wins"
		return -1 if result == "#{human_player} wins"
		return 0 if result == 'draw'

		if is_maximizing
			best_score = -Float::INFINITY
			available_moves(board).each do |pos|
				board_copy = board.dup
				board_copy[pos] = cpu_player
				score = minimax(board_copy, false, cpu_player, human_player)
				best_score = [score, best_score].max
			end
			best_score
		else
			best_score = Float::INFINITY
			available_moves(board).each do |pos|
				board_copy = board.dup
				board_copy[pos] = human_player
				score = minimax(board_copy, true, cpu_player, human_player)
				best_score = [score, best_score].min
			end
			best_score
		end
	end

	# Returns available move positions
	def available_moves(board_str = nil)
		b = board_str || self.board
		b.chars.each_with_index.map { |c, i| c == '-' ? i : nil }.compact
	end

	# Static check_status for minimax
	def static_check_status(board)
		lines = [
			[0,1,2], [3,4,5], [6,7,8],
			[0,3,6], [1,4,7], [2,5,8],
			[0,4,8], [2,4,6]
		]
		lines.each do |line|
			values = line.map { |i| board[i] }
			return "#{values[0]} wins" if values.uniq.length == 1 && values[0] != '-'
		end
		return 'draw' unless board.include?('-')
		'ongoing'
	end

	# Play CPU move if it's CPU's turn
	def play_cpu_move(cpu_player = 'O')
		return false unless self.status == 'ongoing' && self.current_player == cpu_player
		pos = best_move(cpu_player)
		play_move(pos) if pos
	end
end
