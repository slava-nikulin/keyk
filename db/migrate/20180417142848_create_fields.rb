class CreateFields < ActiveRecord::Migration[5.2]
  def change
    create_table :fields do |t|
      t.integer :input_type, comment: "Field's type: password, email or text"
      t.string :title, comment: "Field's title"
      t.string :name, comment: "Field's name"
      t.integer :order, default: 0, comment: "Field's order"
      t.string :value, comment: "Encrypted field's value"
      t.string :enc_salt, comment: "Master password salt"
      t.references :note

      t.timestamps
    end
  end
end
