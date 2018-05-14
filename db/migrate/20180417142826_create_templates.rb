class CreateTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :templates do |t|
      t.string :title, comment: "Template's title"
      t.json :config, comment: "Template's config(fields set with types and order)"
      t.references :user

      t.timestamps
    end
  end
end
