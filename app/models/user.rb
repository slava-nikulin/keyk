class User < ApplicationRecord
  validates :phone, presence: true, if: Proc.new { |user| user.email.blank? }
  validates :email, presence: true, if: Proc.new { |user| user.phone.blank? }
  validates :account, presence: true

  validates :phone, uniqueness: true,
                    format: { with: Constants::PHONE_REGEX, message: :wrong_format },
                    allow_blank: true
  validates :email, uniqueness: true,
                    format: { with: Constants::EMAIL_REGEX, message: :wrong_format },
                    allow_blank: true

  belongs_to :account
  has_many :templates, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :membership_in_groups, foreign_key: 'user_id', class_name: 'GroupRelationship', dependent: :destroy
  has_many :groups, through: :membership_in_groups

  before_save :update_login

  def login=(str)
    assign_attributes(Account.login_key(str) => str)
  end

  private

  def update_login
    account.login = phone || email
    account.save! if valid? && account.changed?
  end
end
