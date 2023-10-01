class AddTrainingPointsAndLevelPointsToFighters < ActiveRecord::Migration[7.0]
  def change
    add_column :fighters, :training_points, :integer
    add_column :fighters, :level_points, :integer
  end
end
