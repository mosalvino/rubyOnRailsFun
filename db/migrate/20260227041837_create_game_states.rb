class CreateGameStates < ActiveRecord::Migration[8.1]
  def change
    create_table :game_states do |t|
      t.string :board
      t.string :current_player
      t.string :status

      t.timestamps
    end
  end
end
