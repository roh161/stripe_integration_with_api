class Api::V1::SessionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    account = Account.find_by(username: params[:username])

    if account && account.authenticate(params[:password])
      token = encode_token(account_id: account.id)
      render json: { 
        token: token,
        message: 'Login successfully',
        account: {
          id: account.id,
          username: account.username,
          email: account.email,
          first_name: account.first_name,
          last_name: account.last_name,
          country_code: account.country_code,
          phone_number: account.phone_number,
          full_phone_number: account.full_phone_number
        }
      }
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  private

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end
