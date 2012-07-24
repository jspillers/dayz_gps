require "spec_helper"

describe GroupMapsController do
  describe "routing" do

    it "routes to #index" do
      get("/group_maps").should route_to("group_maps#index")
    end

    it "routes to #new" do
      get("/group_maps/new").should route_to("group_maps#new")
    end

    it "routes to #show" do
      get("/group_maps/1").should route_to("group_maps#show", :id => "1")
    end

    it "routes to #edit" do
      get("/group_maps/1/edit").should route_to("group_maps#edit", :id => "1")
    end

    it "routes to #create" do
      post("/group_maps").should route_to("group_maps#create")
    end

    it "routes to #update" do
      put("/group_maps/1").should route_to("group_maps#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/group_maps/1").should route_to("group_maps#destroy", :id => "1")
    end

  end
end
