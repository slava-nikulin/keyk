class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table(:accounts) do |t|
      t.string   :login, index: true

      ## Database authenticatable
      t.string   :password_digest, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token, index: true
      t.datetime :reset_password_token_created_at

      ## Confirmable
      t.string   :confirmation_token, index: true
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false
      t.string   :unlock_token
      t.datetime :locked_at

      t.timestamps
    end
  end
end
