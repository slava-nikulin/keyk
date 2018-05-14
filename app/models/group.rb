class Group < ApplicationRecord
  validates :title, presence: true

  has_and_belongs_to_many :notes
  has_many :group_relationships
  has_many :users, through: :group_relationships
end
