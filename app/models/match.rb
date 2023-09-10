class Match < ApplicationRecord
  belongs_to :fighter_1, class_name: 'Fighter'
  belongs_to :fighter_2, class_name: 'Fighter'
  belongs_to :winner, class_name: 'Fighter', optional: true # Winner is optional because a match might not be finished yet
  belongs_to :weight_class, :optional => true
  has_many :rounds

  enum status_id: { pending: 0, completed: 1 }
  enum result_id: { decision: 0, tko: 1, ko: 2 }

  after_initialize :set_default_status, if: :new_record?
  after_initialize :set_default_rounds, if: :new_record?

  before_save :set_weight_class

  def set_weight_class
    higher_weight = [fighter_1.weight, fighter_2.weight].max
    self.weight_class = WeightClass.find_highest_class_for_weight(higher_weight)
  end

  after_initialize :set_default_rounds, if: :new_record?

  def set_default_rounds
    self.max_rounds ||= calculate_default_max_rounds
  end
  def set_default_status
    self.status_id ||= 0
  end

  def self.roll_d20
    rand(1..20)
  end


  def punch(offensive_fighter, defensive_fighter, round, fighter_number)

    return "#{offensive_fighter.name} lays on mat lifeless." if winner_id.present?
    roll = Match.roll_d20

    damage = calculate_damage(offensive_fighter, defensive_fighter)

    case roll
    when 1..5
      score_round(round, fighter_number, 0)
      "missed."
    when 6..10
      score_round(round, fighter_number, damage)
      reduce_health(defensive_fighter, damage)
      if defensive_fighter.endurance <= 0
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "landed a body blow. #{defensive_fighter.name} takes #{damage} damage."
      end
    when 11..15
      score_round(round, fighter_number, damage)
      reduce_health(defensive_fighter, damage)
      if defensive_fighter.endurance <= 0
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "stuck a jab. #{defensive_fighter.name} takes #{damage} damage."
      end
    when 16..18
      score_round(round, fighter_number, damage)
      reduce_health(defensive_fighter, damage)
      if defensive_fighter.endurance <= 0
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "solid head shot. #{defensive_fighter.name} takes #{damage} damage."
      end
    when 19..20
      reduce_health(defensive_fighter, damage)
      round.fighter_1_knockdowns += 1 if fighter_number == 1
      round.fighter_2_knockdowns += 1 if fighter_number == 2
      knockout = determine_knockout(defensive_fighter, damage)
      score_round(round, fighter_number, damage)
      if knockout
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "KNOCKED #{defensive_fighter.name} DOWN. #{defensive_fighter.name} takes #{damage} damage."
      end
    else
      "WTF?"
    end
  end

  def end_match(offensive_fighter, defensive_fighter, damage)
    self.winner = offensive_fighter
    self.ko!
    "HAS KNOCKED OUT #{defensive_fighter.name} inflicting #{damage} damage."
  end

  def score_round(round, fighter_number, damage)
    round.fighter_1_points = damage if fighter_number == 1
    round.fighter_2_points = damage if fighter_number == 2
    round.save
  end

  def reduce_health(defensive_fighter, damage)
    defensive_fighter.endurance -= damage
    defensive_fighter.endurance = 0 if defensive_fighter.endurance < 0
    defensive_fighter.save!
  end

  def calculate_damage(offensive_fighter, defensive_fighter)
    damage = punch_strength(offensive_fighter)
    damage_modifier = dexterity_modifier(defensive_fighter)
    (damage * damage_modifier).round
  end

  def determine_knockout(defensive_fighter, damage)
    case defensive_fighter.speed
    when 3..13
      true
    when 14..17
      if rand(1..100) > 50
        false
      else
        true
      end
    when 18..30
      if ((damage > 10) && (rand(1..100) < 40)) || (defensive_fighter.endurance < 20)
        true
      else
        false
      end
    else
      false
    end
  end

  def dexterity_modifier(defensive_fighter)
    case defensive_fighter.dexterity
    when 1..9
      1
    when 10..14
      0.5
    when 15..18
      0.75
    when 15..17
      2
    when 19..20
      0
    else
      0
    end
  end

  def punch_strength(offensive_fighter)
    case offensive_fighter.strength
    when 3..6
      rand(1..4)
    when 7..10
      rand(1..6)
    when 11..14
      rand(1..8)
    when 15..17
      rand(1..10)
    when 18..20
      rand(1..12)
    when 21..35
      rand(1..12) + 4
    when 36..45
      rand(1..20)
    else
      0
    end
  end

  def outcome(fighter)
    if winner_id == fighter.id
      "Win"
    elsif winner_id.nil?
      "Draw"
    else
      "Loss"
    end
  end
  def opponent(fighter)
    if fighter_1_id == fighter.id
      fighter_2
    else
      fighter_1
    end
  end
  def score_match
    fighter_1_total_points = 0
    fighter_2_total_points = 0

    fighter_1_total_knockdowns = 0
    fighter_2_total_knockdowns = 0

    rounds.each do |round|
      fighter_1_total_points += round.fighter_1_points || 0
      fighter_2_total_points += round.fighter_2_points || 0

      fighter_1_total_knockdowns += round.fighter_1_knockdowns || 0
      fighter_2_total_knockdowns += round.fighter_2_knockdowns || 0
    end

    # Add 10 points for each knockdown
    fighter_1_total_points += fighter_1_total_knockdowns * 10
    fighter_2_total_points += fighter_2_total_knockdowns * 10

    # Save the final scores
    self.fighter_1_final_score = fighter_1_total_points
    self.fighter_2_final_score = fighter_2_total_points

    # Determine the winner based on total points

    if fighter_1_total_points > fighter_2_total_points
      self.winner_id ||= self.fighter_1_id
    elsif fighter_2_total_points > fighter_1_total_points
      self.winner_id ||= self.fighter_2_id
    else
      # It's a draw, set winner_id to nil or handle accordingly
      self.winner_id ||= nil
    end
    self.decision! unless self.ko?

    self.completed!
    # Save the match with the final scores and winner_id set
    self.save

    #Rank the fighters
    self.weight_class.update_fighter_ranks
  end

  def reset_match
    self.fighter_1_final_score = nil
    self.fighter_2_final_score = nil
    self.status_id = 0
    self.winner_id = nil
    self.rounds.destroy_all
    self.save
  end

  def training
    self.fighter_1.update_endurance
    self.fighter_2.update_endurance
  end

  def self.reset_all_matches
    Match.all.each do |match|
      match.reset_match
    end
  end

  private

  def calculate_default_max_rounds
    # Assuming you have access to the ranks of the current fighters
    lowest_rank = [self.fighter_1.rank, self.fighter_2].min

    # Set default_rounds based on the highest rank
    case lowest_rank
    when 1..3
      15
    when 4..6
      8
    when 7..9
      6
    else
      4
    end
  end
end
