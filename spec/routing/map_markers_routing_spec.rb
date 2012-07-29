require "spec_helper"

describe MapMarkersController do
  describe "routing" do

    it "routes to #index" do
      get("/map_markers").should route_to("map_markers#index")
    end

    it "routes to #new" do
      get("/map_markers/new").should route_to("map_markers#new")
    end

    it "routes to #show" do
      get("/map_markers/1").should route_to("map_markers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/map_markers/1/edit").should route_to("map_markers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/map_markers").should route_to("map_markers#create")
    end

    it "routes to #update" do
      put("/map_markers/1").should route_to("map_markers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/map_markers/1").should route_to("map_markers#destroy", :id => "1")
    end

  end
end
