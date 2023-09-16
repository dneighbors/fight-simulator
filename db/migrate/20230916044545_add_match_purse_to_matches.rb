class AddMatchPurseToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :match_purse, :decimal
    add_column :matches, :fighter_1_split, :decimal
    add_column :matches, :fighter_2_split, :decimal
  end
end
