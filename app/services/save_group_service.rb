# Saves Group with given parameters
# params - Hash, required
# user - User object
# group_params - Hash, parameters of group
# content_params - Hash, parameters of group notes and group members
# group_id - integer or nil -group id
class SaveGroupService < BaseService
  def initialize(user:, group_params: {}, content_params: {}, group_id: nil)
    @group_id = group_id
    @group_params = params&.with_indifferent_access&.merge(user: user)
    @content_params = content_params
    super
  end

  def call
    ActiveRecord::Base.transaction do
      begin
        group = Group.find_or_initialize_by(id: @group_id)
        raise Errors::InvalidOperationError if edition_allowed(group)

        group.update_attributes!(group_params)
        assign_users(group)
        assign_notes(group)
      rescue Errors::InvalidOperationError
        errors.add(:base, :unauthorized_operation, message: I18n.t('application.unauthorized_operation'))
        raise ActiveRecord::Rollback
      rescue => e
        errors.add(:base, :save_group, message: e.message)
        raise ActiveRecord::Rollback
      end
    end
    self
  end

  private

  def assign_users(group)
    @content_params[:users].each do |usr|
      db_user = User.find_by(usr[:login])
      if usr[:_destroy]
        group.group_relationships.delete!(db_user)
      elsif group.group_relationships.where(user_id: db_user.id).blank?
        group.group_relationships.create!(user_id: db_user.id)
      end
    end
  end

  def assign_notes(group)
    @content_params[:notes].each do |note|
      db_note = Note.find(note[:id])
      if note[:_destroy]
        group.notes.delete!(db_note)
      elsif group.notes.where(note_id: db_note.id).blank?
        group.notes << db_note
      end
    end
  end

  def edition_allowed(group)
    group.persisted? && !group.has_owner(user_id: @group_params[:user].id)
  end
end
