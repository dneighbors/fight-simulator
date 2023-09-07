namespace :playtest do
  namespace :reset do
    desc "Reset all matches"
    task matches: :environment do
      Match.reset_all_matches
    end

    desc "Reset all fighter endurance scores"
    task endurance: :environment do
      Match.reset_all_matches
    end
  end

  namespace :create do
    desc "Creates 5 random matches per weight class"
    task matches: :environment do
      weight_classes = WeightClass.all

      weight_classes.each do |weight_class|
        5.times do
          fighters_in_weight_class = Fighter.where(weight_class: weight_class).pluck(:id)

          # If not enough fighters in this weight class for a match, skip
          if fighters_in_weight_class.length < 2
            puts "Not enough fighters in #{weight_class.name}. Skipping..."
            next
          end

          random_fighter_ids = fighters_in_weight_class.sample(2)
          random_fighters = Fighter.find(random_fighter_ids)

          available_rounds = [4, 6, 8, 15]
          max_rounds = available_rounds.sample

          Match.create!(
            fighter_1: random_fighters[0],
            fighter_2: random_fighters[1],
            max_rounds: max_rounds,
            status_id: 0,
            weight_class: weight_class
          )

          puts "Match created for #{weight_class.name}"
        end
      end
    end
  end

  namespace :create do
    desc "Creates weight classes"
    task weight_classes: :environment do
      WeightClass.create!(name: "Minimumweight", max_weight: 105)
      WeightClass.create!(name: "Light Flyweight", max_weight: 108)
      WeightClass.create!(name: "Flyweight", max_weight: 112)
      WeightClass.create!(name: "Super Flyweight", max_weight: 115)
      WeightClass.create!(name: "Bantamweight", max_weight: 118)
      WeightClass.create!(name: "Super Bantamweight", max_weight: 122)
      WeightClass.create!(name: "Featherweight", max_weight: 126)
      WeightClass.create!(name: "Super Featherweight", max_weight: 130)
      WeightClass.create!(name: "Lightweight", max_weight: 135)
      WeightClass.create!(name: "Super Lightweight", max_weight: 140)
      WeightClass.create!(name: "Welterweight", max_weight: 147)
      WeightClass.create!(name: "Super Welterweight ", max_weight: 154)
      WeightClass.create!(name: "Middleweight", max_weight: 160)
      WeightClass.create!(name: "Super Middleweight", max_weight: 168)
      WeightClass.create!(name: "Light Heavyweight", max_weight: 175)
      WeightClass.create!(name: "Cruiserweight", max_weight: 200)
      WeightClass.create!(name: "Heavyweight", max_weight: 500)
    end
  end

  namespace :destroy do
    desc "Destroy all fighters and matches and rounds"
    task all: :environment do
      Round.destroy_all
      Match.destroy_all
      Fighter.destroy_all
    end
  end
  namespace :create do
    desc 'Generate 100 random fighters'
    task fighters: :environment do
      100.times do
        Fighter.create!(
          name: Faker::Name.male_first_name + ' ' + Faker::Name.last_name,
          nickname: Faker::Superhero.name,
          birthplace: Faker::Address.city,
        )
      end
    end
  end

  namespace :play do
    desc "Play all matches in the database"
    task matches: :environment do
      Match.all.each do |match|
        match.training
        rounds = match.max_rounds || 4
        (1..rounds).each do |round|
          if match.winner_id.nil?
            new_round = match.rounds.build(round_number: round)
            match.punch(match.fighter_1, match.fighter_2, new_round, 1)
            match.punch(match.fighter_2, match.fighter_1, new_round, 2)
            puts "Round Score: #{match.fighter_1.name} : #{new_round.fighter_1_points} - #{match.fighter_2.name} : #{new_round.fighter_2_points}"
          end
        end
        match.score_match
        match.training

        if match.winner_id.nil?
          puts "Match is a draw!"
        else
          puts "Winner: #{match.winner&.name}"
        end
        puts "#{match.fighter_1.name} : #{match.fighter_1_final_score}"
        puts "#{match.fighter_2.name} : #{match.fighter_2_final_score}"
      end
    end
  end

end




