class WeightClass < ApplicationRecord
  has_many :matches
  has_many :fighters, class_name: 'Fighter', foreign_key: 'weight_class_id'
  has_many :weight_class_ranks

  def self.find_highest_class_for_weight(weight)
    where("max_weight >= ?", weight).order(max_weight: :asc).first
  end

  def update_fighter_ranks
    # Set the previous_rank and highest_rank for all fighters in this weight class
    self.fighters.each do |fighter|
      # Find the rank entry for this fighter and weight class
      current_rank = WeightClassRank.find_by(fighter: fighter, weight_class: self)

      if (fighter.highest_rank.nil?) || (current_rank.rank_number > fighter.highest_rank)
        highest_rank = current_rank.rank_number
      else
        highest_rank = fighter.highest_rank
      end

      # Update the previous_rank and highest_rank for this fighter
      fighter.update(previous_rank: current_rank.rank_number, highest_rank: highest_rank)
    end

    # Delete all existing rank entries for this weight class
    weight_class_ranks.destroy_all

    # Find all fighters in this weight class
    fighters = self.fighters

    # Sort fighters by winning_percentage in descending order
    sorted_fighters = fighters.sort_by { |fighter| -fighter.winning_percentage }

    # Update the ranks in the WeightClassRank model
    sorted_fighters.each_with_index do |fighter, index|
      # Find or create a WeightClassRank entry for this fighter and weight class
      rank_entry = WeightClassRank.find_or_create_by(fighter: fighter, weight_class: self)

      # Update the rank_number starting from 1 (index + 1)
      rank_entry.update(rank_number: index + 1)
    end
  end
end
