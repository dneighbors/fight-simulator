require 'rails_helper'

RSpec.describe "matches/edit", type: :view do
  let(:match) {
    Match.create!(
      max_rounds: 1,
      fighter_1_id: 1,
      fighter_2_id: 1,
      status_id: 1,
      winner_id: 1,
      result_id: 1,
      weight_class_id: 1
    )
  }

  before(:each) do
    assign(:match, match)
  end

  it "renders the edit match form" do
    render

    assert_select "form[action=?][method=?]", match_path(match), "post" do

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
