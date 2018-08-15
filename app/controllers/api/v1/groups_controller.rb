module Api
  module V1
    class GroupsController < ApplicationController
      before_action :find_group, only: %i(show update destroy)
      before_action :save_group, only: %i(create update)

      def index
        @groups = current_user.groups
      end

      def destroy
        if @group.destroy
          render json: { message: I18n.t('api.v1.groups.destroyed') }
        else
          render_errors(@group.errors.full_messages, 500)
        end
      end

      private

      def group_params
        params.require(:group).permit(:title)
      end

      def group_members_params
        filtered_params = params.require(:group).permit(users: %i(login user_role _destroy), notes: %i(id _destroy))
        users = filtered_params.fetch(:users, [])
        users.unshift(login: current_user.account.login, user_role: :owner)
        filtered_params.merge(users: users)
      end

      def save_group
        service_call = SaveGroupService.new(
          owner: current_user,
          group_params: group_params.to_h.with_indifferent_access,
          members_params: group_members_params.to_h.with_indifferent_access,
          group_id: @group&.id,
        ).call

        if service_call.valid?
          @group = service_call.result[:group]
        else
          render_errors(service_call.errors.full_messages, 500)
        end
      end

      def find_group
        @group = current_user.groups.find(params[:id])
      end
    end
  end
end
