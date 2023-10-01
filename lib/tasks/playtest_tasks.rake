namespace :playtest do

  def create_fight_card
    WeightClass.all.each do |weight_class|
      puts "Adding #{weight_class.name} matches to fight card."
      lowest_ranked_fighter_with_suggested_opponent = weight_class.fighters.sort_by(&:rank).reverse.find do |fighter|
        !fighter.suggested_opponents.empty?
      end

      if lowest_ranked_fighter_with_suggested_opponent
        suggested_opponent = lowest_ranked_fighter_with_suggested_opponent.suggested_opponents.first

        Match.create!(
          fighter_1: lowest_ranked_fighter_with_suggested_opponent,
          fighter_2: suggested_opponent,
          status_id: 0,
          weight_class: weight_class
        )
        puts "Match Added: #{lowest_ranked_fighter_with_suggested_opponent.name} (#{lowest_ranked_fighter_with_suggested_opponent&.rank}) vs. #{suggested_opponent.name} (#{suggested_opponent&.rank})"

      else
        puts "No fighters with a suggested opponent found in #{weight_class.name} weight class."
      end
    end
  end

  def play_unplayed_matches
    Match.where(status_id: Match.status_ids['pending']).each do |match|
      match.training
      rounds = match.max_rounds || 4
      (1..rounds).each do |round|
        if match.winner_id.nil?
          new_round = match.rounds.build(round_number: round)
          match.punch(match.fighter_1, match.fighter_2, new_round, 1)
          match.punch(match.fighter_2, match.fighter_1, new_round, 2)
          puts "Round Score: #{match.fighter_1.name} : #{new_round.fighter_1_points} - #{match.fighter_2.name} : #{new_round.fighter_2_points}"
          match.fighter_recovery(round)
          puts "Round Recovery: #{match.fighter_1.name} : #{match.fighter_1.endurance}/#{match.fighter_1.base_endurance} - #{match.fighter_2.name} : #{match.fighter_2.endurance}/#{match.fighter_2.base_endurance}"
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

  namespace :update do
    desc "Update all weight class fighter rankings"
    task rankings: :environment do
      WeightClass.all.each do |weight_class|
        weight_class.update_fighter_ranks
      end
    end
  end

  namespace :create do
    desc "Create initial title holders for all weight classes"
    task rankings: :environment do
      # Delete all records in the titles table
      Title.delete_all

      # Get all weight classes
      weight_classes = WeightClass.all

      weight_classes.each do |weight_class|
        # Find the #1 ranked fighter in this weight class
        top_ranked_fighter = weight_class.fighters.order(:previous_rank).first

        if top_ranked_fighter.present?
          # Create a new title record
          title = Title.new(
            fighter: top_ranked_fighter,
            weight_class: weight_class,
            won_at: Time.now,
            name: "#{weight_class.name} Champion"
          )

          # Save the title record
          title.save

          puts "Created title: #{title.name} for #{top_ranked_fighter.name}"
        else
          puts "No top-ranked fighter found for #{weight_class.name}"
        end
      end
    end
  end

  namespace :create do
    desc "Creates a match for every fighter against every other fighter in the same weight class"
    task matches: :environment do
      weight_classes = WeightClass.all

      weight_classes.each do |weight_class|
        fighters_in_weight_class = Fighter.where(weight_class: weight_class).pluck(:id)

        # If not enough fighters in this weight class for a match, skip
        if fighters_in_weight_class.length < 2
          puts "Not enough fighters in #{weight_class.name}. Skipping..."
          next
        end

        available_rounds = [4, 6, 8, 15]

        fighters_in_weight_class.combination(2).each do |fighter1_id, fighter2_id|
          fighter1 = Fighter.find(fighter1_id)
          fighter2 = Fighter.find(fighter2_id)

          max_rounds = available_rounds.sample

          Match.create!(
            fighter_1: fighter1,
            fighter_2: fighter2,
            max_rounds: max_rounds,
            status_id: 0,
            weight_class: weight_class
          )

          puts "Match created for #{weight_class.name} between #{fighter1.name} and #{fighter2.name}"
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

  namespace :create do
    desc "Set payouts for all matches and pay all fighters."
    task payouts: :environment do
      puts "destroying all ledgers"
      # wipe all ledgers for the fighters
      Ledger.destroy_all

      # find completed matches
      completed_matches = Match.where(status_id: "completed")
      puts "found #{completed_matches.count} completed matches"

      completed_matches.each do |match|
        # set the match purse if nil
        match.set_match_purse
        match.set_split_purses
        match.payout
      end

    end
  end

  namespace :create do
    desc "Set endurance rounds for all fighters where not currently set"
    task endurance_round: :environment do
      puts "setting endurance round"
      Fighter.all.each do |fighter|
        fighter.set_endurance_round
        puts "#{fighter.name} endurance rounds set to #{fighter.endurance_round}"
        fighter.save!
      end
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
    desc 'Generate set number for fighters per weight class'
    task fighters: :environment do
      WeightClass.all.each do |weight_class|
        puts "Number of fighters in #{weight_class.name}: #{weight_class.fighters.count}"
        desired_num_fighters = 10
        num_fighters_to_create = desired_num_fighters - weight_class.fighters.count
        weight = weight_class.max_weight - 2

        if num_fighters_to_create > 0
          puts "  Creating Fighters for #{weight_class.name}"
          num_fighters_to_create.times do
            weight = 201 + rand(1..100) if weight_class.name == "Heavyweight"
            fighter = Fighter.create!(weight: weight)
            puts "     Created fighter #{fighter.name} : #{fighter.weight_class.name} #{fighter.weight}"
          end
        end

      end
    end
  end

  namespace :play do
    desc "Play all unplayed matches in the database"
    task matches: :environment do
      play_unplayed_matches
    end
  end

  namespace :create do
    desc "Create a fight card for the next event"
    task fight_card: :environment do
      create_fight_card
    end
  end

  namespace :update do
    desc "Update all missing fighter points (training and level) to 0"
    task points: :environment do
      Fighter.all.each do |fighter|
        fighter.level_points ||= 0
        fighter.training_points ||= 0
        fighter.save!
      end
    end
  end

  namespace :play do
    desc "Play through ALL possible combinations of unplayed match ups by weight class"
    task all_combinations: :environment do
      loop do
        create_fight_card
        break if Match.where(status_id: Match.status_ids['pending']).empty?

        play_unplayed_matches
      end
    end
  end

end




