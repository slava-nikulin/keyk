class GroupRelationship < ApplicationRecord
  enum user_role: %i(owner editor guest)

  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id }
end
