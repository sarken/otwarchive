class AddForeignKeysAndIndexesToSubscriptionNotifications < ActiveRecord::Migration[5.1]
  def change
    add_index :subscription_notifications, :subscription_id
    add_index :subscription_notifications, :user_id

    add_foreign_key :subscription_notifications, :subscriptions
    add_foreign_key :subscription_notifications, :users
  end
end
