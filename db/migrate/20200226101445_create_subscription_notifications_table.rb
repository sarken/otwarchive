class CreateSubscriptionNotificationsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_notifications do |t|
      t.integer :subscription_id
      t.integer :user_id
      t.integer :creation_id
      t.string :creation_type
    end
  end
end
