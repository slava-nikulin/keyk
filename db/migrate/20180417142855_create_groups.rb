class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :title

      t.timestamps
    end

    create_table :group_relationships do |t|
      t.integer :user_role, comment: "User's role in group"
      t.references :group, index: true
      t.references :user, index: true

      t.timestamps
    end

    create_table :groups_notes do |t|
      t.references :group, index: true
      t.references :note, index: true

      t.timestamps
    end
  end
end
