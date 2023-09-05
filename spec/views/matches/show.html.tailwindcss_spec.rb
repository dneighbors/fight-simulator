require 'rails_helper'

RSpec.describe "matches/show", type: :view do
  before(:each) do
    assign(:match, Match.create!(
      max_rounds: 2,
      fighter_1_id: 3,
      fighter_2_id: 4,
      status_id: 5,
      winner_id: 6,
      result_id: 7,
      weight_class_id: 8
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
    expect(rendered).to match(/8/)
  end
end
