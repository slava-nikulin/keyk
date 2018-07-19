class Group < ApplicationRecord
  validates :title, presence: true

  has_and_belongs_to_many :notes
  has_many :group_relationships, dependent: :destroy
  has_many :users, through: :group_relationships

  def has_owner?(user_id)
    !!owners.select { |usr| usr.id == user_id }.count.nonzero?
  end

  # Can this be made prettier? Too much metaprogramming?
  GroupRelationship.user_roles.keys.each do |role|
    define_method("#{role}s") do
      #  instance_variable_get("@#{role}s") ||
      #    instance_variable_set("@#{role}s", group_relationships.eager_load(:user).where(user_role: role).map(&:user))
      group_relationships.eager_load(:user).where(user_role: role).map(&:user)
    end
  end
end
