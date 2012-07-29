class MapMarkersController < ApplicationController
  # GET /map_markers
  # GET /map_markers.json
  def index
    @map_markers = MapMarker.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @map_markers }
    end
  end

  # GET /map_markers/1
  # GET /map_markers/1.json
  def show
    @map_marker = MapMarker.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @map_marker }
    end
  end

  # GET /map_markers/new
  # GET /map_markers/new.json
  def new
    @map_marker = MapMarker.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @map_marker }
    end
  end

  # GET /map_markers/1/edit
  def edit
    @map_marker = MapMarker.find(params[:id])
  end

  # POST /map_markers
  # POST /map_markers.json
  def create
    @map_marker = MapMarker.new(params[:map_marker])

    respond_to do |format|
      if @map_marker.save
        format.html { redirect_to @map_marker, notice: 'Map marker was successfully created.' }
        format.json { render json: @map_marker, status: :created, location: @map_marker }
      else
        format.html { render action: "new" }
        format.json { render json: @map_marker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /map_markers/1
  # PUT /map_markers/1.json
  def update
    @map_marker = MapMarker.find(params[:id])

    respond_to do |format|
      if @map_marker.update_attributes(params[:map_marker])
        format.html { redirect_to @map_marker, notice: 'Map marker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @map_marker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /map_markers/1
  # DELETE /map_markers/1.json
  def destroy
    @map_marker = MapMarker.find(params[:id])
    @map_marker.destroy

    respond_to do |format|
      format.html { redirect_to map_markers_url }
      format.json { head :no_content }
    end
  end
end
