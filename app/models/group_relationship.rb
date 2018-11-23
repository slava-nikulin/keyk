class GroupRelationship < ApplicationRecord
  enum user_role: %i(owner editor guest)

  belongs_to :user, inverse_of: :membership_in_groups
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id }

  after_destroy :group_must_have_owner

  private

  # TODO: это надо в группе проверять тоже.
  # Нужно посмотреть, можно ли как-то это в одном месте сделать
  def group_must_have_owner
    return if GroupRelationship.where(group_id: group.id, user_role: :owner).count.positive?
    errors.add(:group, :must_have_owner)
    throw :abort
  end
end
