class AddWeightToFighters < ActiveRecord::Migration[7.0]
  def change
    add_column :fighters, :weight, :integer
  end
end
