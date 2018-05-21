# Creates or updates template
# params - Hash, required. Params to create note

class SaveNoteService < BaseService
  def initialize(user:, params:, note_id: nil)
    @note_params = params&.with_indifferent_access&.merge(user: user)
    @note_id = note_id
    @result = {}
    super
  end

  def call
    begin
      note = Note.find_or_initialize_by(id: @note_id)
      note.update_attributes!(@note_params)
      @result[:note] = note
    rescue ArgumentError
      errors.add(:base, :create_note, message: I18n.t('application.invalid_params'))
    rescue => e
      errors.add(:base, :create_note, message: e.message)
    end

    self
  end
end
