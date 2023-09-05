class Fighter < ApplicationRecord
  has_many :matches_as_fighter_1, class_name: 'Match', foreign_key: 'fighter_1_id'
  has_many :matches_as_fighter_2, class_name: 'Match', foreign_key: 'fighter_2_id'
  has_many :won_matches, class_name: 'Match', foreign_key: 'winner_id'

  attribute :punch, default: -> { roll_ability }
  attribute :strength, default: -> { roll_ability }
  attribute :speed, default: -> { roll_ability }
  attribute :dexterity, default: -> { roll_ability }
  attribute :base_endurance, default: -> { roll_base_endurance }

  def self.roll_ability
    dice = Array.new(4) { rand(1..6) }  # Roll four dice and store their results
    ability_score = dice.sort.last(3).sum
    ability_score
  end
  def self.roll_base_endurance
    tens_column = rand(1..10) * 10  # Roll the tens column die and get a value in the tens range
    ones_column = rand(1..10)        # Roll the ones column die and get a value in the ones range
    number = tens_column + ones_column  # Combine the tens and ones columns
    number
  end

end
