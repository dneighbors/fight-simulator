class CreateWeightClassRanks < ActiveRecord::Migration[7.0]
  def change
    create_table :weight_class_ranks do |t|
      t.integer :rank_number
      t.references :fighter, null: false, foreign_key: true
      t.references :weight_class, null: false, foreign_key: true

      t.timestamps
    end
  end
end
