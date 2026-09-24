class CollectionParticipant < ApplicationRecord
  belongs_to :pseud
  has_one :user, through: :pseud
  belongs_to :collection

  after_commit :update_collection_index

  PARTICIPANT_ROLES = ["None", "Owner", "Moderator", "Member", "Invited", "Banned"]
  NONE = PARTICIPANT_ROLES[0]
  OWNER = PARTICIPANT_ROLES[1]
  MODERATOR = PARTICIPANT_ROLES[2]
  MEMBER = PARTICIPANT_ROLES[3]
  INVITED = PARTICIPANT_ROLES[4]
  BANNED = PARTICIPANT_ROLES[5]
  MAINTAINER_ROLES = [PARTICIPANT_ROLES[1], PARTICIPANT_ROLES[2]]
  PARTICIPANT_ROLE_OPTIONS = [ [ts("None"), NONE],
                         [ts("Invited"), INVITED],
                         [ts("Banned"), BANNED],
                         [ts("Member"), MEMBER],
                         [ts("Moderator"), MODERATOR],
                         [ts("Owner"), OWNER] ]

  validates_uniqueness_of :pseud_id, scope: [:collection_id],
    message: ts("That person appears to already be a participant in that collection.")

  validates_presence_of :participant_role
  validates_inclusion_of :participant_role, in: PARTICIPANT_ROLES,
    message: ts("That is not a valid participant role.")

  # TODO: Useful error should be given; it's just a vague one in the update action rn
  validate :not_signed_up, if: proc { |collection_participant| collection_participant.is_banned? }
  def not_signed_up
    # TODO: Needs to apply to subcollections, not just current collection.
    return if collection.challenge.nil?

    errors.add(:base, ts("%{name} could not be banned because they are currently signed up for this challenge.", name: pseud.name)) if ChallengeSignup.in_collection(collection).by_user(pseud.user).any?
  end

  scope :for_user, lambda {|user|
    select("DISTINCT collection_participants.*").
    joins(pseud: :user).
    where('users.id = ?', user.id)
  }

  scope :in_collection, lambda {|collection|
    select("DISTINCT collection_participants.*").
    joins(:collection).
    where('collections.id = ?', collection.id)
  }

  def is_owner? ; self.participant_role == OWNER ; end
  def is_moderator? ; self.participant_role == MODERATOR ; end
  def is_maintainer? ; is_owner? || is_moderator? ; end
  def is_member? ; self.participant_role == MEMBER ; end
  def is_invited? ; self.participant_role == INVITED ; end
  def is_banned? ; self.participant_role == BANNED ; end
  def is_none? ; self.participant_role == NONE ; end

  def approve_membership!
    self.participant_role = MEMBER
    save
  end

  def user_allowed_to_ban?(user, current_role)
    (current_role == INVITED || current_role == MEMBER || current_role == NONE) ? self.collection.user_is_maintainer?(user) : self.collection.user_is_owner?(user)
  end

  # TODO: Banned participants should not be allowed to destroy their participant role.
  def user_allowed_to_destroy?(user)
    self.collection.user_is_maintainer?(user) || self.pseud.user == user
  end

  def user_allowed_to_promote?(user, role)
    (role == MEMBER || role == NONE) ? self.collection.user_is_maintainer?(user) : self.collection.user_is_owner?(user)
  end

  def update_collection_index
    return unless MAINTAINER_ROLES.include?(participant_role) || MAINTAINER_ROLES.include?(participant_role_before_last_save)

    ids = [collection_id]
    ids += collection.children.pluck(:id) if collection.present?
    IndexQueue.enqueue_ids(Collection, ids.compact, :main)
  end
end
