class Title < ApplicationRecord
  belongs_to :fighter
  belongs_to :weight_class
end