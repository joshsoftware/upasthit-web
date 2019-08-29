module AuthHelpers
  def sign_in(staff: nil)
    byebug
    @staff = staff || FactoryBot.create(:staff)
    @staff.set_auth_token
    toggle_session(@staff.auth_token)
    @staff
  end

  def sign_out
    toggle_session
  end

  def toggle_session(auth_token = nil, jwt_token = nil)
    if respond_to?(:header)
      header 'Content-Type', 'application/json'
      header Figaro.env.X_USER_AUTH_TOKEN, auth_token
      header Figaro.env.X_USER_JWT_TOKEN, jwt_token
    else
      request.headers[Figaro.env.X_USER_AUTH_TOKEN] = auth_token
      request.headers[Figaro.env.X_USER_JWT_TOKEN] = jwt_token
    end
  end

  def decoded_token
    JWT.decode(response.headers[@staff.auth_token], Rails.application.secrets.secret_key_base).first
  end
end