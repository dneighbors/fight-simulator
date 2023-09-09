class WeightClass < ApplicationRecord
  has_many :matches
  has_many :fighters
  has_many :weight_class_ranks
  has_many :fighters, through: :weight_class_ranks


  def self.find_highest_class_for_weight(weight)
    where("max_weight >= ?", weight).order(max_weight: :asc).first
  end

  def update_fighter_ranks
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
