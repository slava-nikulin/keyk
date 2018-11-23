class AddTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :tokens do |t|
      t.string :value
      t.string :type
      t.references :account

      t.timestamps
    end
  end
end
