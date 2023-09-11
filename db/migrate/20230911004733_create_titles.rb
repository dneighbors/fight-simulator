class CreateTitles < ActiveRecord::Migration[7.0]
  def change
    create_table :titles do |t|
      t.string :name
      t.bigint :weight_class_id
      t.bigint :fighter_id
      t.datetime :won_at
      t.datetime :lost_at

      t.timestamps
    end
  end
end
