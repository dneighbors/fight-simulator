# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_11_004733) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fighters", force: :cascade do |t|
    t.string "name"
    t.string "nickname"
    t.string "birthplace"
    t.integer "punch"
    t.integer "strength"
    t.integer "base_endurance"
    t.integer "speed"
    t.integer "dexterity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "endurance"
    t.integer "weight"
    t.bigint "weight_class_id"
    t.integer "previous_rank"
    t.integer "highest_rank"
    t.index ["weight_class_id"], name: "index_fighters_on_weight_class_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "max_rounds"
    t.integer "fighter_1_id"
    t.integer "fighter_2_id"
    t.integer "status_id"
    t.integer "winner_id"
    t.integer "result_id"
    t.integer "weight_class_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fighter_1_final_score"
    t.integer "fighter_2_final_score"
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.integer "fighter_1_points"
    t.integer "fighter_2_points"
    t.integer "fighter_1_knockdowns"
    t.integer "fighter_2_knockdowns"
    t.integer "round_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_rounds_on_match_id"
  end

  create_table "titles", force: :cascade do |t|
    t.string "name"
    t.bigint "weight_class_id"
    t.bigint "fighter_id"
    t.datetime "won_at"
    t.datetime "lost_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weight_class_ranks", force: :cascade do |t|
    t.integer "rank_number"
    t.bigint "fighter_id", null: false
    t.bigint "weight_class_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fighter_id"], name: "index_weight_class_ranks_on_fighter_id"
    t.index ["weight_class_id"], name: "index_weight_class_ranks_on_weight_class_id"
  end

  create_table "weight_classes", force: :cascade do |t|
    t.string "name"
    t.integer "max_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "rounds", "matches"
  add_foreign_key "weight_class_ranks", "fighters"
  add_foreign_key "weight_class_ranks", "weight_classes"
end
