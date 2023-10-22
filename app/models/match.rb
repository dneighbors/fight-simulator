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
    return if self.fighter_1_split.present? && self.fighter_2_split.present? # Exit if split purses are already set

    # Determine the fighters' ranks (you may need to adjust how you retrieve ranks)
    fighter_1_rank = fighter_1.rank
    fighter_2_rank = fighter_2.rank

    Rails.logger.info "set_split_purse: Fighter 1 Rank: #{fighter_1_rank}"
    Rails.logger.info "set_split_purse: Fighter 2 Rank: #{fighter_2_rank}"

    # Check if both fighters have no rank (default to 50/50 split)
    if fighter_1_rank.nil? && fighter_2_rank.nil?
      puts "Both fighters have no rank 50/50 split"
      self.fighter_1_split ||= 0.5
      self.fighter_2_split ||= 0.5
    else


      # Determine the split based on ranks and random percentages
      if fighter_1_rank.nil?
        self.fighter_1_split ||= 0.1
        self.fighter_2_split ||= 0.9
      elsif fighter_2_rank.nil?
        self.fighter_2_split ||= 0.1
        self.fighter_1_split ||= 0.9
      else
        # Both fighters have ranks
        # Calculate the rank difference
        rank_difference = (fighter_1_rank - fighter_2_rank).abs

        # Calculate the base split percentage (50%)
        base_split = 0.5

        # Calculate the split factor based on rank difference
        split_factor = (rank_difference + 1) * 0.065  # Adjust this factor as needed

        # Ensure the split factor is within the range [0, 0.5]
        split_factor = [split_factor, 0.45].min
        split_factor = [split_factor, 0.0].max

        # Assign splits based on fighter ranks
        if fighter_1_rank < fighter_2_rank
          self.fighter_1_split ||= base_split + split_factor
          self.fighter_2_split ||= base_split - split_factor
        else
          self.fighter_2_split ||= base_split + split_factor
          self.fighter_1_split ||= base_split - split_factor
        end
      end
    end
  end
  def set_match_purse
    return if self.match_purse.present? # Exit if match_purse is already set

    self.match_purse =
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

  def fighter_recovery(round)
    fighter_1.round_recovery(round)
    fighter_2.round_recovery(round)
  end
  def punch_roll(offensive_fighter, offensive_penalty)
    roll = Match.roll_d20
    adjusted_punch = offensive_fighter.punch + offensive_penalty
    case adjusted_punch
    when 3..6
      roll -= 2
    when 7..10
      roll -= 1
    when 11..14
      roll -= 0
    when 15..17
      roll += 1
    when 18..20
      roll += 2
    when 21..35
      roll += 3
    when 36..45
      roll += 4
    else
      roll -= 2
    end
    roll = 1 if roll < 1
    roll
  end

  def adjust_dexterity(defensive_fighter, defensive_penalty)
    modified_dexterity = defensive_fighter.dexterity + defensive_penalty
    case defensive_fighter.dexterity
    when 1..6
      modified_dexterity -= 2
    when 7..10
      modified_dexterity -= 1
    when 11..14
      modified_dexterity -= 0
    when 15..17
      modified_dexterity += 1
    when 18..20
      modified_dexterity += 2
    when 21..35
      modified_dexterity += 3
    when 36..45
      modified_dexterity += 4
    else
      0
    end
    modified_dexterity
  end

  def set_endurance_penalty(fighter, round)
    penalty = fighter.endurance_round - round
    if penalty < 0
      penalty
    else
      0
    end
  end

  def punch(offensive_fighter, defensive_fighter, round, fighter_number)

    return "#{offensive_fighter.name} lays on mat lifeless." if winner_id.present?
    offensive_penalty = set_endurance_penalty(offensive_fighter, round.round_number)
    defensive_penalty = set_endurance_penalty(defensive_fighter, round.round_number)

    roll = punch_roll(offensive_fighter, offensive_penalty)

    damage = calculate_damage(offensive_fighter, defensive_fighter, offensive_penalty, defensive_penalty)

    debug = true
    debug = "#{offensive_fighter.name} rolled a #{roll}. Punch: #{offensive_fighter.punch} Penalty: #{offensive_penalty}"
    case roll
    when 1..5
      score_round(round, fighter_number, 0)
      "missed. #{debug if debug}"
    when 6..10
      score_round(round, fighter_number, damage)
      reduce_health(defensive_fighter, damage)
      if defensive_fighter.endurance <= 0
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "landed a body blow. #{defensive_fighter.name} takes #{damage} damage. #{debug if debug}"
      end
    when 11..15
      score_round(round, fighter_number, damage)
      reduce_health(defensive_fighter, damage)
      if defensive_fighter.endurance <= 0
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "stuck a jab. #{defensive_fighter.name} takes #{damage} damage. #{debug if debug}"
      end
    when 16..18
      score_round(round, fighter_number, damage)
      reduce_health(defensive_fighter, damage)
      if defensive_fighter.endurance <= 0
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "solid head shot. #{defensive_fighter.name} takes #{damage} damage. #{debug if debug}"
      end
    when 19..30
      reduce_health(defensive_fighter, damage)

      # Check for Technical Knockout
      if fighter_number == 1
        round.fighter_1_knockdowns = 1
        if rounds.sum(:fighter_1_knockdowns) >= 2
          score_round(round, fighter_number, damage)
          end_match(offensive_fighter, defensive_fighter, damage, false)
          return
        end
      elsif fighter_number == 2
        round.fighter_2_knockdowns = 1
        if rounds.sum(:fighter_2_knockdowns) >= 2
          score_round(round, fighter_number, damage)
          end_match(offensive_fighter, defensive_fighter, damage, false)
          return
        end
      end

      # Check for Knockout
      knockout = determine_knockout(defensive_fighter, damage, defensive_penalty)
      score_round(round, fighter_number, damage)
      if knockout
        end_match(offensive_fighter, defensive_fighter, damage)
      else
        "KNOCKED #{defensive_fighter.name} DOWN. #{defensive_fighter.name} takes #{damage} damage. #{debug if debug}"
      end
    else
      "WTF? #{debug if debug}. This should never happen."
    end
  end

  def end_match(offensive_fighter, defensive_fighter, damage, knockout = true)
    self.winner = offensive_fighter
    if knockout
      self.ko!
      "HAS KNOCKED OUT #{defensive_fighter.name} inflicting #{damage} damage."
    else
      self.tko!
      "HAS TECHNICALLY KNOCKED OUT #{defensive_fighter.name} inflicting #{damage} damage."
    end
  end

  def score_round(round, fighter_number, damage)
    if fighter_number == 1
      round.fighter_1_points = damage
      round.fighter_1_points += 10 if round.fighter_1_knockdowns > 0
    end
    if fighter_number == 2
      round.fighter_2_points = damage
      round.fighter_2_points += 10 if round.fighter_2_knockdowns > 0
    end
    round.save
  end

  def reduce_health(defensive_fighter, damage)
    defensive_fighter.endurance -= damage
    defensive_fighter.endurance = 0 if defensive_fighter.endurance < 0
    defensive_fighter.save!
  end

  def calculate_damage(offensive_fighter, defensive_fighter, offensive_penalty, defensive_penalty)
    damage = punch_strength(offensive_fighter, offensive_penalty)
    damage_modifier = dexterity_modifier(defensive_fighter, defensive_penalty)
    (damage * damage_modifier).round
  end

  def determine_knockout(defensive_fighter, damage, defensive_penalty)
    case defensive_fighter.speed + defensive_penalty
    when 3..13
      true
    when 14..17
      if rand(1..100) > 50
        false
      else
        true
      end
    when 18..30
      if ((damage > 10) && (rand(1..100) < 40)) || ((defensive_fighter.endurance < 20) && (rand(1..100) < 50 ))
        true
      else
        false
      end
    else
      false
    end
  end

  def dexterity_modifier(defensive_fighter, defensive_penalty)
    modified_dexterity = adjust_dexterity(defensive_fighter, defensive_penalty)

    case modified_dexterity
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

  def punch_strength(offensive_fighter,offensive_penalty)
    strength = offensive_fighter.strength + offensive_penalty
    case strength
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
    self.fighter_1.update_endurance if self.fighter_1.endurance < 15
    self.fighter_2.update_endurance if self.fighter_2.endurance < 15
    self.fighter_1.train
    self.fighter_2.train
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
    [self.fighter_1.total_matches, self.fighter_2.total_matches].max
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
