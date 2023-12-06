Rails.configuration.stripe = { 
  :publishable_key => 'pk_test_51LrLnwFyrjWvOKgCcOTOBdjn6VWKxijpRaZ9wklmxZ6tZsyuTPymQb2xrUYlOPitlC8SztT5P6TKW7Z4C0Qb5jRe00iTvGm98d',
  :secret_key => 'sk_test_51LrLnwFyrjWvOKgCrN7ffWHMiGVhcDqWdjn2b5QvodbtTXmlhXLK6lssaf1287VBNPZtac4ewSv92KJOzho64gsg00xuBlWxsZ'
} 

Stripe.api_key = Rails.configuration.stripe[:secret_key]
