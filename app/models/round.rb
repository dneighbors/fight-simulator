class Round < ApplicationRecord
  belongs_to :match

  after_initialize :init

  def init
    self.fighter_1_knockdowns ||= 0
    self.fighter_2_knockdowns ||= 0
  end
end
