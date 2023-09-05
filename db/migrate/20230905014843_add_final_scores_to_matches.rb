class AddFinalScoresToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :fighter_1_final_score, :integer
    add_column :matches, :fighter_2_final_score, :integer
  end
end
