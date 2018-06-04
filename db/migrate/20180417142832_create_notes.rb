class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes do |t|
      t.string :title, comment: "Note's title"
      t.integer :order, default: 0, comment: "Note's order"
      t.references :user

      t.timestamps
    end
  end
end
