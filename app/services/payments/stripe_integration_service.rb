module Payments
	class StripeIntegrationService

		attr_accessor :errors

		def initialize(user_id)
			@user_id = user_id
			@user = Account.find_by(id: user_id) rescue nil
			@errors = []
		end

		def stripe_payment_intent(payment_attr)
			response = nil
			begin
				payment_attr[:stripe_id] = @user.stripe_id
				
				if !@user.stripe_id?
					payment_attr[:stripe_id] = create_customer&.id
					update_customer_stripe_id(payment_attr[:stripe_id])
				end

				response = Stripe::PaymentIntent.create({
				  amount: (payment_attr[:amount] * 100).to_i,
				  currency: 'usd',
				  payment_method_types: ['card'],
				  customer: payment_attr[:stripe_id],
				  confirm: true,
				  # off_session: true,
				  description: payment_attr[:description],
				  payment_method: 'pm_card_visa_debit',
				  setup_future_usage: 'off_session',
				  metadata: payment_attr[:metadata]
				})
			
			rescue Stripe::StripeError => e
		  	@errors << e.message
		  end
		  response
		end

		def stripe_charge(payment_attr)
			begin
				payment_attr[:stripe_id] = @user.stripe_id

				if !@user.stripe_id?
					payment_attr[:stripe_id] = create_customer&.id
					update_customer_stripe_id(payment_attr[:stripe_id])
				end

				return Stripe::Charge.create({
		      amount: (payment_attr[:amount] * 100).to_i,
		      currency: payment_attr[:currency] || 'usd',
		      customer: payment_attr[:stripe_id],
		      description: payment_attr[:description],
		      source: payment_attr[:stripe_card_id],
		      metadata: payment_attr[:metadata]
		    })
		  
		  rescue Stripe::StripeError => e
		  	@errors << e.message
		  end
		end

		def create_customer
			begin
				customer = Stripe::Customer.create({
					email: @user.email, 
					name: @user.first_name,
					shipping: {
						address: {
							line1: '510 Townsend St',
		          postal_code: '98140',
		          city: 'San Francisco',
		          state: 'CA',
		          country: 'US',
						},
						name: @user.first_name,
						phone: @user.phone_number
					}
				})
			rescue Stripe::StripeError => e
		  	@errors << e.message
		  end
		end

		def retrieve_customer(stripe_id)
			begin
				Stripe::Customer.retrieve(stripe_id)
			rescue Stripe::StripeError => e
		  	@errors << e.message
		  end
		end

		def update_customer_stripe_id(stripe_id)
			@user.update_columns(stripe_id: stripe_id)
		end

		def create_product(name)
			begin
				return Stripe::Product.create({name: name})
			rescue Stripe::StripeError => e
				@errors << e.message
			end
		end

		def create_price(amount, product_id)
			begin
				return Stripe::Price.create(
  				{currency: 'usd', unit_amount: amount, product: product_id},
				)
			rescue Stripe::StripeError => e
				@errors << e.message
			end
		end

		def create_payment_link(price_id, metadata)
			begin
				return Stripe::PaymentLink.create({
					line_items: [{price: price_id, quantity: 1}],
					# metadata: {type: '', id: ''}
					metadata: metadata
				})
			rescue Stripe::StripeError => e
				@errors << e.message
			end	
		end

		def update_payment_link(id, active)
			begin
				return Stripe::PaymentLink.update(id,{active: active})
			rescue Stripe::StripeError => e
				@errors << e.message
			end
		end

	end
end