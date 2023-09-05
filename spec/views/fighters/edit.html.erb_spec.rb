require 'rails_helper'

RSpec.describe "fighters/edit", type: :view do
  let(:fighter) {
    Fighter.create!(
      name: "MyString",
      nickname: "MyString",
      birthplace: "MyString",
      punch: 1,
      strength: 1,
      base_endurance: 1,
      speed: 1,
      dexterity: 1,
      endurance: 1
    )
  }

  before(:each) do
    assign(:fighter, fighter)
  end

  it "renders the edit fighter form" do
    render

    assert_select "form[action=?][method=?]", fighter_path(fighter), "post" do

      assert_select "input[name=?]", "fighter[name]"

      assert_select "input[name=?]", "fighter[nickname]"

      assert_select "input[name=?]", "fighter[birthplace]"

      assert_select "input[name=?]", "fighter[punch]"

      assert_select "input[name=?]", "fighter[strength]"

      assert_select "input[name=?]", "fighter[base_endurance]"

      assert_select "input[name=?]", "fighter[speed]"

      assert_select "input[name=?]", "fighter[dexterity]"

      assert_select "input[name=?]", "fighter[base_endurance]"
    end
  end
end
