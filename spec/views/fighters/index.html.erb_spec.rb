require 'rails_helper'

RSpec.describe "fighters/index", type: :view do
  before(:each) do
    assign(:fighters, [
      Fighter.create!(
        name: "Name",
        nickname: "Nickname",
        birthplace: "Birthplace",
        punch: 2,
        strength: 3,
        speed: 4,
        dexterity: 5,
        base_endurance: 6,
        endurance: 7
      ),
      Fighter.create!(
        name: "Name",
        nickname: "Nickname",
        birthplace: "Birthplace",
        punch: 2,
        strength: 3,
        speed: 4,
        dexterity: 5,
        base_endurance: 6,
        endurance: 6
      )
    ])
  end

  it "renders a list of fighters" do
    render
    assert_select "h2", text: "Name".to_s, count: 2
    assert_select "dl>dd", text: "Nickname".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: 4.to_s, count: 2
    assert_select "tr>td", text: 5.to_s, count: 2
    assert_select "tr>td", text: 6.to_s, count: 2
  end
end
