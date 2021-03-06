class ApplicationController < ActionController::API
  include ::ActionController::Serialization

  before_action :authorized

  def encode_token(payload)
    # don't forget to hide your secret in an environment variable
    JWT.encode(payload, 'my_s3cr3t')
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token

    if auth_header
      begin
        JWT.decode(auth_header, 'my_s3cr3t', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user

    if decoded_token
      # decoded_token=> [{"user_id"=>2}, {"alg"=>"HS256"}]
      # or nil if we can't decode the token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end

  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: { message: 'Please Log In' }, status: :unauthorized unless logged_in?
  end
end
