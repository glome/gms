class CreateGmsAccounts < ActiveRecord::Migration
  def change
    create_table :gms_accounts do |t|
      t.string :name
      t.string :domain
      t.string :resource
      t.string :alias
      t.integer :user_id
      t.timestamps
      t.timestamp :deleted_at
    end
  end
end
