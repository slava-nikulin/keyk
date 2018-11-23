class ConfirmToken < Token
  private

  def regenerate_token
    regenerate_value if value.blank?
  end
end
