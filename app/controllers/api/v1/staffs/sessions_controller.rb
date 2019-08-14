# frozen_string_literal: true

module Api
  module V1
    module Staffs
      class SessionsController < BaseController
        before_action :validate_mobile_number, only: :sync
        include AuthenticationConcern

        def sync
          service = SyncService.new(staff_params)
          if service.sync
            render json: service.result
          else
            render json: {errors: service.errors.messages}, status: 400
          end
        end

        private

        def validate_mobile_number
          render json: {message: I18n.t("error.absent_mobile_no")}, status: 422 unless staff_params[:mobile_number].present?
        end

        def staff_params
          {mobile_number: request.headers[Figaro.env.X_USER_MOB_NUM]}
        end
      end
    end
  end
end
