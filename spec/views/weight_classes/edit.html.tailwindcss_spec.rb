require 'rails_helper'

RSpec.describe "weight_classes/edit", type: :view do
  let(:weight_class) {
    WeightClass.create!(
      name: "MyString",
      max_weight: 1
    )
  }

  before(:each) do
    assign(:weight_class, weight_class)
  end

  it "renders the edit weight_class form" do
    render

    assert_select "form[action=?][method=?]", weight_class_path(weight_class), "post" do

      assert_select "input[name=?]", "weight_class[name]"

      assert_select "input[name=?]", "weight_class[max_weight]"
    end
  end
end
