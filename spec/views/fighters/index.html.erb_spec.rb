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
        endurance: 6
      ),
      Fighter.create!(
        name: "Name",
        nickname: "Nickname",
        birthplace: "Birthplace",
        punch: 2,
        strength: 3,
        speed: 4,
        dexterity: 5,
        endurance: 6
      )
    ])
  end

  it "renders a list of fighters" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Nickname".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Birthplace".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(4.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(5.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(6.to_s), count: 2
  end
end
