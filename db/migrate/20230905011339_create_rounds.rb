class CreateRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.references :match, null: false, foreign_key: true
      t.integer :fighter_1_points
      t.integer :fighter_2_points
      t.integer :fighter_1_knockdowns
      t.integer :fighter_2_knockdowns
      t.integer :round_number

      t.timestamps
    end
  end
end
