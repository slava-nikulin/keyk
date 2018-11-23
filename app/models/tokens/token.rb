class Token < ApplicationRecord
  has_secure_token :value
  validates :value, uniqueness: true
  validates :account, presence: true

  belongs_to :account

  after_create :regenerate_token

  private

  def regenerate_token
    regenerate_value if value.blank?
  end
end
