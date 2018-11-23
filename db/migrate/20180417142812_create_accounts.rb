class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table(:accounts) do |t|
      t.string   :login, index: true

      ## Database authenticatable
      t.string   :password_digest, null: false, default: ""

      ## Confirmable
      t.datetime :confirmed_at

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.timestamps
    end
  end
end
