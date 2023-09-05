class RenameEnduranceToBaseEnduranceAndAddEnduranceInFighters < ActiveRecord::Migration[7.0]
  def change
    rename_column :fighters, :endurance, :base_endurance
    add_column :fighters, :endurance, :integer
  end
end
