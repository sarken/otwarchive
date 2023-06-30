require 'faker'

FactoryBot.define do
  factory :prompt_restriction do

    # By default, we allow descriptions and fandom, characer, and relationship
    # tags.
    trait :no_details do
      description_allowed { false }
      fandom_num_allowed { 0 }
      character_num_allowed { 0 }
      relationship_num_allowed { 0 }
    end
  end
end
