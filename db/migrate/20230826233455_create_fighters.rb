class CreateFighters < ActiveRecord::Migration[7.0]
  def change
    create_table :fighters do |t|
      t.string :name
      t.string :nickname
      t.string :birthplace
      t.integer :punch
      t.integer :strength
      t.integer :endurance
      t.integer :speed
      t.integer :dexterity

      t.timestamps
    end
  end
end
