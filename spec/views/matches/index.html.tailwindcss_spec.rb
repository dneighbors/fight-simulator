require 'rails_helper'

RSpec.describe "matches/index", type: :view do
  before(:each) do
    assign(:matches, [
      Match.create!(
        rounds: 2,
        fighter_1_id: 3,
        fighter_2_id: 4,
        status_id: 5,
        winner_id: 6,
        result_id: 7,
        weight_class_id: 8
      ),
      Match.create!(
        rounds: 2,
        fighter_1_id: 3,
        fighter_2_id: 4,
        status_id: 5,
        winner_id: 6,
        result_id: 7,
        weight_class_id: 8
      )
    ])
  end

  it "renders a list of matches" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(4.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(5.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(6.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(7.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(8.to_s), count: 2
  end
end
