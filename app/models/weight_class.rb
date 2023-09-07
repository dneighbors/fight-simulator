class WeightClass < ApplicationRecord
  has_many :matches

  def self.find_highest_class_for_weight(weight)
    where("max_weight >= ?", weight).order(max_weight: :asc).first
  end
end
