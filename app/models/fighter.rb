class Fighter < ApplicationRecord
  has_many :matches_as_fighter_1, class_name: 'Match', foreign_key: 'fighter_1_id'
  has_many :matches_as_fighter_2, class_name: 'Match', foreign_key: 'fighter_2_id'
  has_many :won_matches, class_name: 'Match', foreign_key: 'winner_id'
  has_many :titles
  belongs_to :weight_class
  has_many :weight_classes, through: :weight_class_ranks
  has_many :weight_class_ranks
  has_many :ledgers


  attribute :name, default: -> { random_name }
  attribute :nickname, default: -> { random_nickname }
  attribute :birthplace, default: -> { random_birthplace }
  attribute :punch, default: -> { roll_ability }
  attribute :strength, default: -> { roll_ability }
  attribute :speed, default: -> { roll_ability }
  attribute :dexterity, default: -> { roll_ability }
  attribute :weight, default: -> { roll_weight }
  attribute :base_endurance, default: -> { roll_base_endurance }

  after_initialize :set_endurance
  after_initialize :set_weight_class
  after_create :set_rankings

  def self.random_name
    Faker::Name.male_first_name + ' ' + Faker::Name.last_name
  end

  def self.random_birthplace
    Faker::Address.city
  end

  def self.random_nickname
    Faker::Superhero.name
  end

  def set_rankings
    self.weight_class.update_fighter_ranks
  end

  def set_endurance
    self.endurance ||= self.base_endurance
  end

  def set_weight_class
    self.weight_class ||= WeightClass.find_highest_class_for_weight(self.weight)
  end
  def reset_endurance
    self.endurance = self.base_endurance
  end

  def self.roll_weight
    if rand() <= 0.99 # 99% chance
      rand(90..225)
    else # 1% chance
      rand(226..350)
    end
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

  def winning_percentage
    total_matches = wins + losses + draws

    # Guard clause to prevent division by zero
    return 0.0 if total_matches == 0

    (wins.to_f / total_matches).round(3)
  end
  def completed_matches
    (matches_as_fighter_1.or(matches_as_fighter_2)).where(status_id: :completed)
  end

  def pending_matches
    (matches_as_fighter_1.or(matches_as_fighter_2)).where(status_id: :pending)
  end
  def titles_list
    titles.map(&:name).join(', ')
  end

  def current_champion?
    titles.where(lost_at: nil).exists?
  end

  def total_winnings
    self.ledgers.where("amount > 0").sum(:amount)
  end

  def past_champion?
    titles.where.not(lost_at: nil).exists?
  end
  def rank
    self.weight_class.weight_class_ranks.find_by(fighter_id: self.id)&.rank_number
  end
  def update_endurance
    additional_endurance = Fighter.roll_base_endurance
    new_endurance = self.endurance + additional_endurance
    if new_endurance > self.base_endurance
      self.endurance = self.base_endurance
    else
      self.endurance = new_endurance
    end
    self.save!
  end

  def self.reset_endurance
    Fighter.all.each do |fighter|
      fighter.reset_endurance
      fighter.save
    end
  end
end
