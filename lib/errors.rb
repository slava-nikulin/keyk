module Errors
  class InvalidLoginError < StandardError
  end

  class InvalidOperationError < StandardError
  end

  class DuplicateLoginError < StandardError
  end

  class ConfirmationFailed < StandardError
  end
end
