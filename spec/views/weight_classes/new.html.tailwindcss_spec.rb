require 'rails_helper'

RSpec.describe "weight_classes/new", type: :view do
  before(:each) do
    assign(:weight_class, WeightClass.new(
      name: "MyString",
      max_weight: 1
    ))
  end

  it "renders new weight_class form" do
    render

    assert_select "form[action=?][method=?]", weight_classes_path, "post" do

      assert_select "input[name=?]", "weight_class[name]"

      assert_select "input[name=?]", "weight_class[max_weight]"
    end
  end
end
