require "rails_helper"

RSpec.describe FightersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/fighters").to route_to("fighters#index")
    end

    it "routes to #new" do
      expect(get: "/fighters/new").to route_to("fighters#new")
    end

    it "routes to #show" do
      expect(get: "/fighters/1").to route_to("fighters#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/fighters/1/edit").to route_to("fighters#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/fighters").to route_to("fighters#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/fighters/1").to route_to("fighters#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/fighters/1").to route_to("fighters#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/fighters/1").to route_to("fighters#destroy", id: "1")
    end
  end
end
