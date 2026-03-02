class GameState < ApplicationRecord
	after_initialize :initialize_board

	def initialize_board
		self.board ||= '---------'
		self.current_player ||= 'X'
		self.status ||= 'ongoing'
	end

	def board_matrix
		board.chars.each_slice(3).to_a
	end

	def make_move(position)
		return false unless status == 'ongoing' && board[position] == '-'
		board[position] = current_player
		self.current_player = current_player == 'X' ? 'O' : 'X'
		self.status = game_status
		save
	end

	def game_status
		win_lines = [
			[0, 1, 2], [3, 4, 5], [6, 7, 8],
			[0, 3, 6], [1, 4, 7], [2, 5, 8],
			[0, 4, 8], [2, 4, 6]
		]
		win_lines.each do |line|
			values = line.map { |i| board[i] }
			return "#{values[0]} wins" if values.uniq.length == 1 && values[0] != '-'
		end
		return 'draw' unless board.include?('-')
		'ongoing'
	end

	def best_cpu_move(cpu_symbol = 'O')
		moves = available_positions
		best_score = -Float::INFINITY
		best_position = nil
		moves.each do |pos|
			board_copy = board.dup
			board_copy[pos] = cpu_symbol
			score = minimax(board_copy, false, cpu_symbol, cpu_symbol == 'X' ? 'O' : 'X')
			if score > best_score
				best_score = score
				best_position = pos
			end
		end
		best_position
	end

	def minimax(board_state, maximizing, cpu_symbol, human_symbol)
		result = static_game_status(board_state)
		return 1 if result == "#{cpu_symbol} wins"
		return -1 if result == "#{human_symbol} wins"
		return 0 if result == 'draw'

		if maximizing
			best_score = -Float::INFINITY
			available_positions(board_state).each do |pos|
				board_copy = board_state.dup
				board_copy[pos] = cpu_symbol
				score = minimax(board_copy, false, cpu_symbol, human_symbol)
				best_score = [score, best_score].max
			end
			best_score
		else
			best_score = Float::INFINITY
			available_positions(board_state).each do |pos|
				board_copy = board_state.dup
				board_copy[pos] = human_symbol
				score = minimax(board_copy, true, cpu_symbol, human_symbol)
				best_score = [score, best_score].min
			end
			best_score
		end
	end

	def available_positions(board_str = nil)
		b = board_str || board
		b.chars.each_with_index.map { |cell, idx| cell == '-' ? idx : nil }.compact
	end

	def static_game_status(board_state)
		win_lines = [
			[0, 1, 2], [3, 4, 5], [6, 7, 8],
			[0, 3, 6], [1, 4, 7], [2, 5, 8],
			[0, 4, 8], [2, 4, 6]
		]
		win_lines.each do |line|
			values = line.map { |i| board_state[i] }
			return "#{values[0]} wins" if values.uniq.length == 1 && values[0] != '-'
		end
		return 'draw' unless board_state.include?('-')
		'ongoing'
	end

	def make_cpu_move(cpu_symbol = 'O')
		return false unless status == 'ongoing' && current_player == cpu_symbol
		pos = best_cpu_move(cpu_symbol)
		make_move(pos) if pos
	end
end
