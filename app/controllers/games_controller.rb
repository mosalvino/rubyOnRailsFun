class GamesController < ApplicationController
  def start
    @game = GameState.last || GameState.create
    render :start
  end

  def play
    @game = GameState.last || GameState.create
    mode = params[:mode] || 'friend'
    # Set starting player for friend mode if specified
    if params[:player] && @game.board == '---------'
      @game.current_player = params[:player]
      @game.save
    end
    if params[:position]
      @game.play_move(params[:position].to_i)
      # Only trigger CPU move in single-player mode
      if mode == 'single' && @game.status == 'ongoing' && @game.current_player == 'O'
        @game.play_cpu_move('O')
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
