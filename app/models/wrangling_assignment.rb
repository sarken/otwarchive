class WranglingAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :fandom
  
  validates_uniqueness_of :user_id, scope: :fandom_id
  validates_presence_of :user
  validates_presence_of :fandom
  validate :canonicity
  def canonicity
    unless fandom.canonical?
      errors.add(:base, ts("Sorry, only canonical fandoms can be assigned to wranglers."))
      # errors.add(:fandom, ts("%{fandom} is not canonical. Only canonical fandoms can be assigned to wranglers.", fandom: fandom.name))
    end
  end
  
end
