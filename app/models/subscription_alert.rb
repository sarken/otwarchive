class SubscriptionAlert < ApplicationRecord
  validates_presence_of :creation_id
  validates_presence_of :creation_type

  belongs_to :creation, polymorphic: true
  has_many :inbox_comments, as: :feedback_comment

  # Each user with a relevant subscription gets a new inbox comment. This way,
  # users can delete them or mark them as read on an individual basis.
  after_create :create_inbox_comments
  def create_inbox_comments
    subscriber_ids.each do |subscriber_id|
      InboxComment.create(item_type: self.class, item_id: id,
        user_id: subscriber_id)
    end
  end

  def subscriber_ids
    work = creation.respond_to?(:work) ? creation.work : creation
    Subscription.for_work(work).pluck(:user_id)
  end
end
