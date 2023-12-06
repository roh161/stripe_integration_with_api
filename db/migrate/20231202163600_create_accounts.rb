class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :full_phone_number
      t.integer :country_code
      t.bigint :phone_number
      t.string :email
      t.string :password_digest
      t.string :stripe_id

      t.timestamps
    end
  end
end
