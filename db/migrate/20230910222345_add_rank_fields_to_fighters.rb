class AddRankFieldsToFighters < ActiveRecord::Migration[7.0]
  def change
    add_column :fighters, :previous_rank, :integer
    add_column :fighters, :highest_rank, :integer
  end
end
