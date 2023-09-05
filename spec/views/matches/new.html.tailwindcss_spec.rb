require 'rails_helper'

RSpec.describe "matches/new", type: :view do
  before(:each) do
    assign(:match, Match.new(
      max_rounds: 1,
      fighter_1_id: 1,
      fighter_2_id: 1,
      status_id: 1,
      winner_id: 1,
      result_id: 1,
      weight_class_id: 1
    ))
  end

  it "renders new match form" do
    render

    assert_select "form[action=?][method=?]", matches_path, "post" do

      assert_select "input[name=?]", "match[max_rounds]"

      assert_select "input[name=?]", "match[fighter_1_id]"

      assert_select "input[name=?]", "match[fighter_2_id]"

      assert_select "input[name=?]", "match[status_id]"

      assert_select "input[name=?]", "match[winner_id]"

      assert_select "input[name=?]", "match[result_id]"

      assert_select "input[name=?]", "match[weight_class_id]"
    end
  end
end
