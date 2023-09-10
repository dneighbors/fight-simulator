class WeightClass < ApplicationRecord
  has_many :matches
  has_many :fighters, class_name: 'Fighter', foreign_key: 'weight_class_id'
  has_many :weight_class_ranks

  def self.find_highest_class_for_weight(weight)
    where("max_weight >= ?", weight).order(max_weight: :asc).first
  end

  def update_fighter_ranks
    # Set the previous_rank for all fighters in this weight class
    self.fighters.each(&method(:set_previous_rank))

    # Delete all existing rank entries for this weight class
    weight_class_ranks.destroy_all

    # Find all fighters in this weight class
    fighters = self.fighters

    # Calculate a composite score for each fighter
    sorted_fighters = fighters.sort_by do |fighter|
      # Winning percentage as the first factor (higher is better)
      winning_percentage = -fighter.winning_percentage

      # Number of fights as the second factor (higher is better)
      number_of_fights = -(fighter.matches_as_fighter_1.count + fighter.matches_as_fighter_2.count)

      # Highest previous rank as the third factor (lower is better)
      highest_rank = fighter.highest_rank || Float::INFINITY

      [winning_percentage, number_of_fights, highest_rank]
    end

    # Update the ranks in the WeightClassRank model
    sorted_fighters.each_with_index do |fighter, index|
      # Find or create a WeightClassRank entry for this fighter and weight class
      rank_entry = WeightClassRank.find_or_create_by(fighter: fighter, weight_class: self)

      # Update the rank_number starting from 1 (index + 1)
      rank_entry.update(rank_number: index + 1)
    end

    # Update the ranks in the WeightClassRank model
    sorted_fighters.each_with_index do |fighter, index|
      # Find or create a WeightClassRank entry for this fighter and weight class
      rank_entry = WeightClassRank.find_or_create_by(fighter: fighter, weight_class: self)

      # Update the rank_number starting from 1 (index + 1)
      rank_entry.update(rank_number: index + 1)
    end

    self.fighters.each(&method(:set_highest_rank))

  end

  private

  def set_highest_rank(fighter)
    current_rank = WeightClassRank.find_by(fighter: fighter, weight_class: self)

    if (fighter.highest_rank.nil?) || (current_rank.rank_number < fighter.highest_rank)
      highest_rank = current_rank.rank_number
    else
      highest_rank = fighter.highest_rank
    end

    # Update the highest_rank for this fighter
    fighter.update(highest_rank: highest_rank)
  end

  def set_previous_rank(fighter)
    current_rank = WeightClassRank.find_by(fighter: fighter, weight_class: self)

    if current_rank.nil?
      previous_rank = nil
    else
      previous_rank = current_rank.rank_number
    end

    # Update the previous_rank and highest_rank for this fighter
    fighter.update(previous_rank: previous_rank)
  end
end
