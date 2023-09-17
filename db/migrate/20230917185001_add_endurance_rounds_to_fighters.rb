class AddEnduranceRoundsToFighters < ActiveRecord::Migration[7.0]
  def change
    add_column :fighters, :endurance_rounds, :integer
  end
end
