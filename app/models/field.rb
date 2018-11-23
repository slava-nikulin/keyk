# Model describes note's fields, such as password, email, login. Stores values in database in encrypted form
class Field < ApplicationRecord
  enum input_type: %i(text email password)
  belongs_to :note, inverse_of: :fields

  validates :title, :value, :note, :name, presence: true
  validates :name, uniqueness: { scope: :note_id }

  # attribute :value,
  #           :encrypted_field,
  #           salt: enc_salt || (self.enc_salt = SecureRandom.random_bytes(ActiveSupport::MessageEncryptor.key_len))

  # TODO: move to attributes api value object
  after_initialize :deserialize_value
  before_save :serialize_value

  private

  def deserialize_value
    if persisted?
      self.value = value.present? ? cypher.decrypt_and_verify(value) : value
    else
      self.enc_salt = SecureRandom.urlsafe_base64(ActiveSupport::MessageEncryptor.key_len)
    end
  end

  def serialize_value
    if value_changed? && value.present?
      self.value = cypher.encrypt_and_sign(value)
    end
  end

  def cypher
    key = ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(:security, :secret_key)).
                                      generate_key(enc_salt, ActiveSupport::MessageEncryptor.key_len)
    @cypher ||= ActiveSupport::MessageEncryptor.new(key)
  end
end
