# Model describes note's fields, such as password, email, login. Stores values in database in encrypted form
class Field < ApplicationRecord
  enum input_type: %i(text email password)
  belongs_to :note, inverse_of: :fields

  validates :title, :value, :note, :name, presence: true
  validates :name, uniqueness: { scope: :note_id }

  attribute :value, :encrypted_field
end
