class RenameRoundsToMaxRoundsInMatches < ActiveRecord::Migration[7.0]
  def change
    rename_column :matches, :rounds, :max_rounds
  end
end
