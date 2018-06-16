class Group < ApplicationRecord
  validates :title, presence: true

  has_and_belongs_to_many :notes
  has_many :group_relationships, dependent: :destroy
  has_many :users, through: :group_relationships

  def has_owner?(user_id)
    group_relationships.where(user_role: :owner, user_id: user_id).count.nonzero?
  end
end
