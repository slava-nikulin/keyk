module Security
  # Encryption/Decription of 'value' attribute for Field model
  # NOTE: currently note in use
  class EncryptedFieldValueType < ActiveRecord::Type::Value
    def initialize(salt)
      @salt = salt
    end

    def serialize(value)
      cypher.encrypt_and_sign(value) if value.present?
    end

    def deserialize(encrypted_data)
      encrypted_data.present? ? cypher.decrypt_and_verify(encrypted_data) : encrypted_data
    end

    private

    def cypher
      key = ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(:security, :secret_key)).
                                        generate_key(@salt, ActiveSupport::MessageEncryptor.key_len)
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
