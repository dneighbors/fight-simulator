require 'rails_helper'

RSpec.describe "weight_classes/show", type: :view do
  before(:each) do
    assign(:weight_class, WeightClass.create!(
      name: "Name",
      max_weight: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
  end
end
