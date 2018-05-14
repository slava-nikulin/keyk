class GroupRelationship < ApplicationRecord
  enum user_role: %i(owner editor guest)

  validates :user, :group, presence: true
  belongs_to :user
  belongs_to :group
end
