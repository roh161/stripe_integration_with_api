module Payments
	class CreditCardService

		attr_accessor :errors

		def initialize(user_id, card)
			@user_id = user_id
			@user = Account.find_by(id: user_id)
			@errors = []
			@card = card
		end

		def create_credit_card
			if @card[:stripe_card_id].blank?
				card_id = create_stripe_credit_card
				if @errors.blank?
					@card[:stripe_card_id] = card_id
				end
			end
			
			if @card[:stripe_card_id].present?
				@user.credit_cards.create_with(@card).find_or_create_by(stripe_card_id: @card[:stripe_card_id])
			else
				@errors << "No Stripe card id available"
			end
			
			@card[:stripe_card_id]
		end

		def create_stripe_credit_card
			begin
		    if !@user.stripe_id?
		    	service = Payments::StripeIntegrationService.new(@user_id)
		    	customer = service.create_customer
		    	customer = nil if service.errors.present?
		    else
		    	customer = Stripe::Customer.retrieve(@user.stripe_id)
		    end
		  	
		  	return generate_payment_method
		    # customer.sources.create(source: generate_token).id if customer.present?
		  #   return Stripe::Customer.create_source(
				#   customer.id,
				#   {source: generate_token},
				# )&.id
		  rescue Stripe::StripeError => e
		  	@errors << e.message
		  end
	  end

	  def generate_token
	  	begin
	    	Stripe::Token.create(
		      card: {
		        number: @card[:number],
		        exp_month: @card[:month],
		        exp_year: @card[:year],
		        cvc: @card[:cvc]
		      }
		    ).id
		  rescue Stripe::StripeError => e
		  	@errors << e.message
		  end
  	end

  	def generate_payment_method
  		begin
		    Stripe::PaymentMethod.create({
          type: 'card',
          card: {
            number: @card[:number],
            exp_month: @card[:month].to_i,
            exp_year: @card[:year].to_i,
            cvc: @card[:cvc],
          },
        }).id
		  rescue Stripe::StripeError => e
		  	@errors << e.message
		  end
  	end

	end
end