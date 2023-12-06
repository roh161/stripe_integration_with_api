class CreatePaymentTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_transactions do |t|
      t.references :account, foreign_key: true
      t.json :payload

      t.timestamps
    end
  end
end
