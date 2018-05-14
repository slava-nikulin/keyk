# Model, that describes security note. Note contains fields with secret information such as email, login, password
class Note < ApplicationRecord
  validates :title, :user, presence: true

  belongs_to :user
  belongs_to :template
  has_many :fields, -> { order(:order) }, autosave: true, dependent: :destroy, inverse_of: :note
  has_and_belongs_to_many :groups

  accepts_nested_attributes_for :fields
end
