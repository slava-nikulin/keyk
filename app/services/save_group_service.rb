# Saves Group with given parameters
# owner - User that owns group
# group_params - Hash, parameters of group
# members_params - Hash, parameters of group notes and group members
#  Example - { users: [{login: 'john@doe.com'}], notes: [{id: 1}] }
#  key - users. Users to be assingned to group
#  value - array of Hashes
#    key - login
#    value - user's login
#    key - role
#    value - one of possible roles [owner editor guest]
#  key - notes. Notes to be assingned to group
#  value - array of Hashes
#    key - id
#    value - note's id
# group_id - integer or nil -group id
class SaveGroupService < BaseService
  def initialize(owner:, group_params: {}, members_params: {}, group_id: nil)
    @owner = owner
    @group_id = group_id
    @group_params = group_params&.with_indifferent_access
    @members_params = members_params
    super
  end

  def call
    ActiveRecord::Base.transaction do
      begin
        group = Group.find_or_initialize_by(id: @group_id)
        raise Errors::InvalidOperationError unless edition_allowed?(group)

        group.update_attributes!(@group_params)
        assign_users(group)
        assign_notes(group)
        result[:group] = group
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
    @members_params[:users].each do |usr|
      db_user = Account.find_by(login: usr[:login])&.user
      next if db_user.blank?

      if usr[:_destroy]
        group.group_relationships.find_by(user_id: db_user.id)&.delete
      elsif group.group_relationships.where(user_id: db_user.id).blank?
        group.group_relationships.create!(user_id: db_user.id, user_role: usr[:role])
      end
    end
  end

  def assign_notes(group)
    @members_params[:notes].each do |note|
      db_note = Note.find_by(id: note[:id])
      next if db_note.blank?

      if note[:_destroy]
        group.notes.delete(db_note) # excess DELETE query if db_note if not in group. But to check, EXISTS query needed
      elsif group.notes.where(id: db_note.id).blank?
        group.notes << db_note
      end
    end
  end

  # User can edit group only if he owns it or if it is a new group
  def edition_allowed?(group)
    group.new_record? || group.has_owner?(@owner.id)
  end
end
