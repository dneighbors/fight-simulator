class CreateMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :matches do |t|
      t.integer :rounds
      t.integer :fighter_1_id
      t.integer :fighter_2_id
      t.integer :status_id
      t.integer :winner_id
      t.integer :result_id
      t.integer :weight_class_id

      t.timestamps
    end
  end
end
