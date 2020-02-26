class SubscriptionNotification < ApplicationRecord
  validates_presence_of :subscription_id
  validates_presence_of :user_id
  validates_presence_of :creation_id
  validates_presence_of :creation_type

  belongs_to :subscription
  belongs_to :user

  belongs_to :creation, polymorphic: true
  belongs_to :chapter, class_name: "Chapter", foreign_key: "creation_id"
  belongs_to :work, class_name: "Work", foreign_key: "creation_id"
end
