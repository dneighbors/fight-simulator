class Match < ApplicationRecord
  belongs_to :fighter_1, class_name: 'Fighter'
  belongs_to :fighter_2, class_name: 'Fighter'
  belongs_to :winner, class_name: 'Fighter', optional: true # Winner is optional because a match might not be finished yet
  belongs_to :weight_class, :optional => true
  has_many :rounds

  enum status_id: { pending: 0, completed: 1 }
  enum result_id: { decision: 0, tko: 1, ko: 2 }

  before_save :set_default_status, if: :new_record?

  before_save :set_weight_class
  before_save :set_default_rounds
  before_save :set_match_purse
  before_save :set_split_purses

  def set_split_purses
    self.fighter_1_split ||= 0.5
    self.fighter_2_split ||= 0.5
  end
  def set_match_purse
    self.match_purse ||=
      case highest_rank
      when 1..3
        if fighter_1.past_champion? || fighter_2.past_champion? || fighter_1.current_champion? || fighter_2.current_champion?
          (rand(1..20) + 10) * 1000
        elsif fighter_1.current_champion? && fighter_2.current_champion?
          (rand(1..20) + 12) * 1000
        else
          rand(1..20) * 1000
        end
      when 4..6
        rand(1..12) * 1000
      when 7..9
        rand(1..10) * 1000
      else
        rand(1..8) * 1000
      end
    modifer =
      case most_matches
      when 10..15
        4
      when 16..20
        5
      when 21..25
        6
      when 26..30
        7
      when 31..35
        8
      when 36..40
        9
      when 41..45
        10
      else
        2
      end
    self.match_purse *= modifer
  end
  def set_weight_class
    higher_weight = [fighter_1.weight, fighter_2.weight].max
    self.weight_class = WeightClass.find_highest_class_for_weight(higher_weight)
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


    if self.winner_id.present?
      # Get the Current Champion
      current_champion = self.weight_class.current_champion
      Rails.logger.info "Current Champion: #{current_champion&.name} #{current_champion&.id}"
      Rails.logger.info "Winner: #{self.winner&.name} #{self.winner&.id}"


      if current_champion
        # Check if the current champion is one of the fighters in the match
        if current_champion.id == self.fighter_1_id || current_champion.id == self.fighter_2_id
          Rails.logger.info "Current Champion is one of the fighters in the match"
          if self.winner_id != current_champion.id
            Rails.logger.info "Current Champion lost the match"
          current_champion.titles.find_by(weight_class_id: self.weight_class_id, lost_at: nil).update(lost_at: Time.now)

          # Generate a new title record for the winner
          Title.create(
            fighter_id: self.winner_id,
            weight_class_id: self.weight_class_id,
            name: "#{self.weight_class.name} Champion",
            won_at: Time.now
          )
          end
        end
      end
    end

    self.decision! unless self.ko?

    self.completed!
    self.payout
    # Save the match with the final scores and winner_id set
    self.save

    # Rank the fighters
    self.weight_class.update_fighter_ranks
  end

  def payout
    self.fighter_1.ledgers.create(description: "Fight purse for match against #{self.fighter_2.name}", amount: self.fighter_1_split * self.match_purse, transaction_date: Time.now)
    self.fighter_2.ledgers.create(description: "Fight purse for match against #{self.fighter_1.name}", amount: self.fighter_2_split * self.match_purse, transaction_date: Time.now)
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

  def lowest_rank
    [self.fighter_1.rank, self.fighter_2.rank].min
  end

  def highest_rank
    [self.fighter_1.rank, self.fighter_2.rank].max
  end

  def most_matches
    [self.fighter_1.matches.count, self.fighter_2.matches.count].max
  end

  private

  def set_default_rounds
    # Assuming you have access to the ranks of the current fighters

    # Set default_rounds based on the highest rank
    self.max_rounds ||=
      case self.lowest_rank
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
