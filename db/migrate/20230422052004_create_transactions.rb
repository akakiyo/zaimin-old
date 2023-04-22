class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :user, foreign_key: true
      t.string :name, null: false
      t.integer :price, null: false
      t.datetime :date_of_use, null: false
      t.datetime :due_date, null:false
      t.timestamps
    end
  end
end
