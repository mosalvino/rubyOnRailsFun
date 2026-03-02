class GamesController < ApplicationController
  def start
    @game = GameState.last || GameState.create
    render :start
  end

  def play
    @game = GameState.last || GameState.create
    game_mode = params[:mode] || 'friend'
    starting_player = params[:player]

    if starting_player && @game.board == '---------'
      @game.current_player = starting_player
      @game.save
    end

    move_position = params[:position]&.to_i
    if move_position
      @game.make_move(move_position)
      if game_mode == 'single' && @game.status == 'ongoing' && @game.current_player == 'O'
        @game.make_cpu_move('O')
      end
    end

    render :play
  end

  def reset
    GameState.delete_all
    @game = GameState.create
    render :reset
  end
end
