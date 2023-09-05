require 'rails_helper'

RSpec.describe "fighters/new", type: :view do
  before(:each) do
    assign(:fighter, Fighter.new(
      name: "MyString",
      nickname: "MyString",
      birthplace: "MyString",
      punch: 1,
      strength: 1,
      base_endurance: 1,
      speed: 1,
      dexterity: 1,
      endurance: 1
    ))
  end

  it "renders new fighter form" do
    render

    assert_select "form[action=?][method=?]", fighters_path, "post" do

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
