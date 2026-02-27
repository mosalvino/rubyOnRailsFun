class GamesController < ApplicationController
  def start
    @game = GameState.last || GameState.create
    render :start
  end

  def play
    @game = GameState.last || GameState.create
    if params[:position]
      @game.play_move(params[:position].to_i)
    end
    render :play
  end

  def reset
    GameState.delete_all
    @game = GameState.create
    render :reset
  end
end
