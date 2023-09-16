class CreateLedgers < ActiveRecord::Migration[7.0]
  def change
    create_table :ledgers do |t|
      t.references :fighter, null: false, foreign_key: true
      t.string :description
      t.decimal :amount
      t.date :transaction_date

      t.timestamps
    end
  end
end
