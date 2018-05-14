module Api
  module V1
    class TemplatesController < ApplicationController
      before_action :find_template, only: %i(show update destroy)
      before_action :save_template, only: %i(create update)

      def index
        @templates = current_user.templates
      end

      def destroy
        if @template.destroy
          render json: { message: I18n.t('api.v1.templates.destroyed') }
        else
          render_errors(@template.errors.full_messages, 500)
        end
      end

      private

      def template_params
        params.require(:template).permit(:title, config: [fields: %i(title input_type order name)])
      end

      def save_template
        service_call = SaveTemplateService.new(
          user: current_user,
          params: template_params.to_h,
          template_id: @template&.id,
        ).call

        if service_call.valid?
          @template = service_call.result[:template]
        else
          render_errors(service_call.errors.full_messages, 500)
        end
      end

      def find_template
        @template = current_user.templates.find(params[:id])
      end
    end
  end
end
