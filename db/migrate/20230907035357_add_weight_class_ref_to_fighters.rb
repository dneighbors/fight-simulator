class AddWeightClassRefToFighters < ActiveRecord::Migration[7.0]
  def change
    add_reference :fighters, :weight_class
  end
end
