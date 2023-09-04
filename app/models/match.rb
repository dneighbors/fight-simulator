class Match < ApplicationRecord
  belongs_to :fighter_1, class_name: 'Fighter'
  belongs_to :fighter_2, class_name: 'Fighter'
  belongs_to :winner, class_name: 'Fighter', optional: true  # Winner is optional because a match might not be finished yet
  belongs_to :weight_class


  def self.roll_d20
    rand(1..20)
  end

  def punch(offensive_fighter, defensive_fighter)
    roll = Match.roll_d20

    damage = calculate_damage(offensive_fighter, defensive_fighter)

    case roll
    when 1..5
      "missed."
    when 6..10
      "landed a body blow. #{defensive_fighter.name} takes #{damage} damage."
    when 11..15
      "stuck a jab. #{defensive_fighter.name} takes #{damage} damage."
    when 16..18
      "solid head shot. #{defensive_fighter.name} takes #{damage} damage."
    when 19..20
      "knock out blow. #{defensive_fighter.name} takes #{damage} damage."
    else
      "WTF?"
    end
  end

  def calculate_damage(offensive_fighter,defensive_fighter)
    damage = punch_strength(offensive_fighter)
    damage_modifier = dexterity_modifier(defensive_fighter)
    damage = (damage * damage_modifier).round
    damage
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
end
