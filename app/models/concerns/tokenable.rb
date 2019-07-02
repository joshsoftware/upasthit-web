module Tokenable
  extend ActiveSupport::Concern

  def jwt_token(exp: 5.hour.from_now)
    payload = { resource_id: id, resource_type: self.class.to_s }
    respond_to?(:remember_me) && remember_me ? payload[:remember] = true : payload[:exp] = exp.to_i

    JWT.encode(payload, auth_token)
  end
end
