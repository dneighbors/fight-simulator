require "rails_helper"

RSpec.describe WeightClassesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/weight_classes").to route_to("weight_classes#index")
    end

    it "routes to #new" do
      expect(get: "/weight_classes/new").to route_to("weight_classes#new")
    end

    it "routes to #show" do
      expect(get: "/weight_classes/1").to route_to("weight_classes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/weight_classes/1/edit").to route_to("weight_classes#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/weight_classes").to route_to("weight_classes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/weight_classes/1").to route_to("weight_classes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/weight_classes/1").to route_to("weight_classes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/weight_classes/1").to route_to("weight_classes#destroy", id: "1")
    end
  end
end
