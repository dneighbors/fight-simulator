class Fighter < ApplicationRecord
  has_many :matches_as_fighter_1, class_name: 'Match', foreign_key: 'fighter_1_id'
  has_many :matches_as_fighter_2, class_name: 'Match', foreign_key: 'fighter_2_id'
  has_many :won_matches, class_name: 'Match', foreign_key: 'winner_id'

  attribute :punch, default: -> { roll_ability }
  attribute :strength, default: -> { roll_ability }
  attribute :speed, default: -> { roll_ability }
  attribute :dexterity, default: -> { roll_ability }
  attribute :base_endurance, default: -> { roll_base_endurance }

  after_initialize :set_endurance

  def set_endurance
    self.endurance ||= self.base_endurance
  end

  def reset_endurance
    self.endurance = self.base_endurance
  end

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
  def wins
    won_matches.count
  end

  def losses
    # Count matches where the fighter participated but did not win
    # and the match is completed and not a draw
    Match.where("(fighter_1_id = ? OR fighter_2_id = ?) AND winner_id != ? AND winner_id IS NOT NULL AND status_id = 1", self.id, self.id, self.id).count
  end

  def draws
    # Count matches where the fighter participated, match is completed, and there's no winner
    Match.where("(fighter_1_id = ? OR fighter_2_id = ?) AND winner_id IS NULL AND status_id = 1", self.id, self.id).count
  end
  def knockouts
    won_matches.where(result_id: Match.result_ids['ko']).count
  end
  def self.reset_endurance
    Fighter.all.each do |fighter|
      fighter.reset_endurance
      fighter.save
    end
  end
end
