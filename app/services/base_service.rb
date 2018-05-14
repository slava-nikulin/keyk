class BaseService
  extend ActiveModel::Naming
  attr_accessor :result
  attr_reader :errors

  def initialize(_)
    @errors = ActiveModel::Errors.new(self)
  end

  def valid?
    errors.empty?
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  class << self
    def human_attribute_name(attr, _ = {})
      attr
    end

    def lookup_ancestors
      [self]
    end
  end
end
