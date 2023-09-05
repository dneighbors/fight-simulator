require 'rails_helper'

RSpec.describe "fighters/show", type: :view do
  before(:each) do
    assign(:fighter, Fighter.create!(
      name: "Name",
      nickname: "Nickname",
      birthplace: "Birthplace",
      punch: 2,
      strength: 3,
      speed: 4,
      dexterity: 5,
      base_endurance: 6,
      endurance: 7
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Nickname/)
    expect(rendered).to match(/Birthplace/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
