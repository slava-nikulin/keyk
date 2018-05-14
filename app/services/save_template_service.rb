# Creates or updates template
# params - Hash, required
# title - Template title
# config - Note's blueprint
# user
class SaveTemplateService < BaseService
  def initialize(user:, params:, template_id: nil)
    @template_params = params&.with_indifferent_access&.merge(user: user)
    @template_id = template_id
    @result = {}
    super
  end

  def call
    if arguments_valid? && config_valid?
      begin
        template = Template.find_or_initialize_by(id: @template_id)
        template.update_attributes!(@template_params)
        @result[:template] = template
      rescue => e
        errors.add(:base, :create_template, message: e.message)
      end
    end

    self
  end

  private

  def config_valid?
    return true if @template_params[:config].blank?

    unless @template_params[:config].key?(:fields) && @template_params[:config][:fields].present? &&
        @template_params[:config][:fields].all? { |c| c.key?(:title) && c.key?(:input_type) && c.key?(:name) }

      errors.add(:base, :invalid_config, message: I18n.t('application.service.template.invalid_config'))
      return false
    end

    true
  end

  def arguments_valid?
    if @template_params.blank?
      errors.add(:base, :invalid_params, message: I18n.t('application.invalid_params'))
      return false
    end

    true
  end
end
