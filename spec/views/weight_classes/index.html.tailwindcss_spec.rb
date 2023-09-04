require 'rails_helper'

RSpec.describe "weight_classes/index", type: :view do
  before(:each) do
    assign(:weight_classes, [
      WeightClass.create!(
        name: "Name",
        max_weight: 2
      ),
      WeightClass.create!(
        name: "Name",
        max_weight: 2
      )
    ])
  end

  it "renders a list of weight_classes" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
  end
end
