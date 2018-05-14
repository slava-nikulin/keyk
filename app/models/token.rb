class Token < ApplicationRecord
  has_secure_token :value

  validates :account, presence: true
  validates :value, uniqueness: true

  belongs_to :account

  after_create { regenerate_value }
end
