class CreateSubscriptionNotificationsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_notifications do |t|
      t.integer :subscription_id
      t.integer :user_id
    end
  end
end
