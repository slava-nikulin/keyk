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
  has_many :membership_in_groups, foreign_key: 'user_id', class_name: 'GroupRelationship', dependent: :destroy, inverse_of: :user
  has_many :groups, through: :membership_in_groups

  before_save :update_login
  before_destroy :delete_owned_groups, prepend: true

  def login=(str)
    assign_attributes(Account.login_key(str) => str)
  end

  def notes
    Note.where(user_id: id) + (groups.eager_load(:notes).map(&:notes).first || []) # returns collection_proxy
  end

  def owned_groups
    membership_in_groups.eager_load(:group).where(user_role: :owner).map(&:group)
  end

  def can_edit_note?(note)
    note.user_id == id || note.new_record? ||
      membership_in_groups.
        eager_load(:group).
        where(user_role: %i(owner editor)).
        map(&:group).any? do |group|
          group.notes.any? { |n| n.id == note.id }
        end
  end

  private

  def delete_owned_groups
    owned_groups.each(&:destroy!)
  end

  def update_login
    account.login = phone || email
    account.save! if valid? && account.changed?
  end
end
