# Creates or updates template
# params - Hash, required. Params to create note

class SaveNoteService < BaseService
  def initialize(user:, params:, note_id: nil)
    @user = user
    @note_params = params&.with_indifferent_access
    @note_id = note_id
    super
  end

  def call
    begin
      note = Note.find_or_initialize_by(id: @note_id)
      if @user.can_edit_note?(note)
        @note_params&.merge!(user: @user) if note.new_record?
        note.update_attributes!(@note_params)
        @result[:note] = note
      else
        errors.add(:base, :save_note, message: I18n.t('application.unauthorized_operation'))
      end
    rescue => e
      errors.add(:base, :save_note, message: e.message)
    end

    self
  end
end
