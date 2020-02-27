class CreateSubscriptionAlertsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :subscription_alerts do |t|
      t.references :creation, polymorphic: true

      t.timestamps
    end
  end
end
