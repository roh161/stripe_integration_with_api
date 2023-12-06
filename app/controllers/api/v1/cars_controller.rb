class Api::V1::CarsController < ApplicationController
    include JwtAuthenticatable
    skip_before_action :verify_authenticity_token
    before_action :load_car, only: [:payment]
    
    def create
        @car = Car.new(car_params)
    
        if @car.save
          render json: { message: 'Car created successfully', car: @car }
        else
          render json: { error: @car.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def payment
        success = validate_card_details(card_params['number'],card_params['month'],card_params['year'],card_params['cvc'])
        return render json: {success: false, message: success}, status: 422 unless success.nil?
        return render json: {success: false, message: 'Please update Car Price'}, status: 422 if @car.price <= 0.0
        # stripe_card_id = 
        #   if params[:card_id].present?
        #     params[:card_id]
        #   else
        #     Payments::CreditCardService.new(current_user.id, card_params).create_credit_card
        #   end
        stripe_service = Payments::StripeIntegrationService.new(current_user.id)
        # stripe_service.stripe_charge(payment_attributes.merge(stripe_card_id: stripe_card_id))
        payment_response = stripe_service.stripe_payment_intent(payment_attributes)
  
        if payment_response&.id.present?
          PaymentTransaction.create(account_id: current_user.id, payload: payment_attributes)
          render json: {success: true, payment_id: payment_response&.id, payment_message: "Payment confirmed", message: "Car Payment is done."}, status: 200
        else
          render json: {success: false, message: 'Unable to initiate payment process due to the car not existing'}, status: 422
        end
    end

    private

    def car_params
        params.require(:car).permit(:price, :make, :model, :color)
    end

    def card_params
        params.require(:card).permit(:number, :month, :year, :cvc)
      end

    def payment_attributes
        {
          amount: @car.price,
          currency: 'usd',
          description: "#{@car.make} #{@car.model} Car is Purchased by #{current_user.username}",
          metadata: {type: 'Car', id: @car.id, name: 'Car Payment'},
        }
      end

    def load_car
        @car = Car.find_by(id: params[:id])
  
        if @car.blank?
          render json: {
              message: "Car with id #{params[:id]} doesn't exists"
          }, status: :not_found
        end
    end

    def validate_card_details(number,month,year,cvc)
        return "Card number is Invalid" unless number.to_s.length == 16
        return "Enter a valid month" unless (month.to_i>0 && month.to_i <=12)
        return "Enter a valid year" unless  year.to_i >= Time.now.year
        return "CVV no is invalid" unless cvc.to_s.length == 3
    end

end
