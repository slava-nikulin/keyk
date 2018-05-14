module Security
  # Encryption/Decription of value attribute for Field model
  class EncryptedFieldValueType < ActiveRecord::Type::Value
    def serialize(value)
      cypher.encrypt_and_sign(value) if value.present?
    end

    def deserialize(encrypted_data)
      encrypted_data.present? ? cypher.decrypt_and_verify(encrypted_data) : encrypted_data
    end

    private

    def cypher
      salt = Rails.application.credentials.dig(:security, :salt)
      key = ActiveSupport::KeyGenerator.new(Rails.application.credentials.dig(:security, :secret_key)).
        generate_key(salt, Rails.application.credentials.dig(:security, :key_size))
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
