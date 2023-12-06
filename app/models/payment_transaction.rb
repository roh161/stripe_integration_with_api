class PaymentTransaction < ApplicationRecord
    belongs_to :account, foreign_key: :account_id
end
