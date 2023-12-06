class Api::V1::AccountsController < ApplicationController
    protect_from_forgery with: :null_session
    
    def create
      account = Account.new(account_params)
  
      if account.save
        token = encode_token(account_id: account.id)
        render json: { 
          message: 'Account created successfully',
          account: {
            id: account.id,
            username: account.username,
            email: account.email,
            first_name: account.first_name,
            last_name: account.last_name,
            country_code: account.country_code,
            phone_number: account.phone_number,
            full_phone_number: account.full_phone_number
          },
          token: token
        }, status: :created
      else
        render json: { error: account.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def account_params
      params.permit(:username, :email, :password, :first_name, :last_name, :country_code, :phone_number, :full_phone_number)
    end
  
    def encode_token(payload)
      JWT.encode(payload, Rails.application.secret_key_base)
    end
end
  