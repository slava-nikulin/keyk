class Group < ApplicationRecord
  validates :title, presence: true

  has_and_belongs_to_many :notes
  has_many :group_relationships, dependent: :destroy
  has_many :users, through: :group_relationships

  def has_owner?(user_id)
    !!owners.select { |usr| usr.id == user_id }.count.nonzero?
  end

  def destroy!
    group_relationships.delete_all
    super
  end

  GroupRelationship.user_roles.keys.each do |role|
    define_method("#{role}s") do
      group_relationships.eager_load(user: :account).where(user_role: role).map(&:user)
    end
  end
end
