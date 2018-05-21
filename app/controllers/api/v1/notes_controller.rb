module Api
  module V1
    class NotesController < ApplicationController
      before_action :find_note, except: %i(index)
      before_action :save_note, only: %i(create update)

      def index
        @notes = current_user.notes
      end

      def destroy
        if current_account.destroy
          render json: { message: I18n.t('api.v1.notes.destroyed') }
        else
          render_errors(current_account.errors.full_messages, 500)
        end
      end

      private

      def note_params
        params.require(:note).permit(:title, :user_id, fields: %i(input_type title name order value))
      end

      def save_note
        service_call = SaveNoteService.new(note_params.to_h).call
        if service_call.valid?
          @account = service_call.result[:note]
        else
          render_errors(service_call.errors.full_messages, 500)
        end
      end

      def find_note
        @note = current_user.notes.find(params[:id])
      end
    end
  end
end
