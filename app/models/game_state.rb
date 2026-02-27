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
end
