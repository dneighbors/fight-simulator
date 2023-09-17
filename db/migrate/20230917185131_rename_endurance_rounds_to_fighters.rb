class RenameEnduranceRoundsToFighters < ActiveRecord::Migration[7.0]
  def change
    rename_column :fighters, :endurance_rounds, :endurance_round
  end
end
