class InboxComment < ApplicationRecord
  validates_presence_of :user_id
  validates_presence_of :item_id

  belongs_to :user
  belongs_to :feedback_comment, class_name: 'Comment', foreign_key: "item_id"
  belongs_to :item, polymorphic: true

  # Filters inbox comments by read and/or replied to and sorts by date
  scope :find_by_filters, lambda { |filters|
    read = case filters[:read]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end
    replied_to = case filters[:replied_to]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end
    direction = (filters[:date]&.upcase == "ASC" ? "created_at ASC" : "created_at DESC")

    includes(feedback_comment: :pseud).
      order(direction).
      where(read: read, replied_to: replied_to)
  }

  scope :for_homepage, -> {
    where(read: false).
      order(created_at: :desc).
      limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_ON_HOMEPAGE)
  }

  scope :join_item, -> {
    joins("LEFT JOIN comments ON (inbox_comments.item_id = comments.id AND inbox_comments.item_type = 'Comment')
           LEFT JOIN subscription_alerts ON (inbox_comments.item_id = subscription_alerts.id AND inbox_comments.item_type = 'SubscriptionAlert')")
  }

  # Get only the inbox_comments with a comment that exists or with a
  # subscription alert.
  scope :with_item, -> {
    join_item.where(
      "(comments.id IS NOT NULL AND comments.is_deleted = 0) OR
      (inbox_comments.item_type = 'SubscriptionAlert')"
    )
  }

  # Gets the number of unread comments
  def self.count_unread
    where(read: false).count
  end
end
