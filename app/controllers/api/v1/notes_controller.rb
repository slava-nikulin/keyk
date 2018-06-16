module Api
  module V1
    class NotesController < ApplicationController
      before_action :find_note, except: %i(index create)
      before_action :save_note, only: %i(create update)

      def index
        @notes = current_user.notes
      end

      def destroy
        if @note.destroy
          render json: { message: I18n.t('api.v1.notes.destroyed') }
        else
          render_errors(@note.errors.full_messages, 500)
        end
      end

      private

      def note_params
        params.require(:note).
          permit(:title, :order, fields_attributes: %i(id input_type title name order value _destroy))
      end

      def save_note
        service_call = SaveNoteService.new(
          user: current_user,
          params: note_params.to_h,
          note_id: @note&.id,
        ).call

        if service_call.valid?
          @note = service_call.result[:note]
        else
          render_errors(service_call.errors.full_messages, 500)
        end
      end

      def find_note
        @note = current_user.notes.detect { |n| n.id == params[:id].to_i }
        raise ActiveRecord::RecordNotFound if @note.nil?
      end
    end
  end
end
