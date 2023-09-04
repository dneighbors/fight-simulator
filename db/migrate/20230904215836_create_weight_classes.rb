class CreateWeightClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :weight_classes do |t|
      t.string :name
      t.integer :max_weight

      t.timestamps
    end
  end
end
