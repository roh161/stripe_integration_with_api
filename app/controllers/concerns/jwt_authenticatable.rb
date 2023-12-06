module JwtAuthenticatable
    extend ActiveSupport::Concern
  
    included do
      before_action :authenticate_request
    end
  
    def authenticate_request
      authorization_header = request.headers['token']
  
      if authorization_header
        token = authorization_header
        decoded_token = decode_token(token)
  
        if decoded_token
          @current_user = Account.find(decoded_token['account_id'])
        else
          render json: { error: 'Invalid token' }, status: :unauthorized
        end
      else
        render json: { error: 'token header is missing or malformed' }, status: :unauthorized
      end
    end
  
    def current_user
      @current_user
    end
  
    private
  
    def decode_token(token)
      begin
        JWT.decode(token, Rails.application.secret_key_base)[0]
      rescue JWT::DecodeError
        nil
      end
    end
end
  