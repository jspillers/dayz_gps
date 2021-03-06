class GroupMapsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :check_membership, only: [:show, :update]
  before_filter :check_ownership, only: [:destroy]

  # GET /group_maps/1
  # GET /group_maps/1.json
  def show
    @asset_host = DayzGps::Application.config.action_controller.asset_host ||
                  "http://localhost:#{request.port.inspect}"
    respond_to do |format|
      format.html
      format.json { render json: @group_map.map_markers }
    end
  end

  # GET /group_maps/new
  # GET /group_maps/new.json
  def new
    @group_map = GroupMap.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_map }
    end
  end

  # GET /group_maps/1/edit
  def edit
    @group_map = GroupMap.find(params[:id])
  end

  # POST /group_maps
  # POST /group_maps.json
  def create
    @group_map = GroupMap.new(params[:group_map])
    @group_map.owner == current_user
    @group_map.users << current_user

    respond_to do |format|
      if @group_map.save
        format.html { redirect_to @group_map, notice: 'Group map was successfully created.' }
        format.json { render json: @group_map, status: :created, location: @group_map }
      else
        format.html { render action: "new" }
        format.json { render json: @group_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /group_maps/1
  # PUT /group_maps/1.json
  def update
    respond_to do |format|
      if @group_map.update_attributes(params[:group_map])
        format.html { redirect_to @group_map, notice: 'Group map was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_maps/1
  # DELETE /group_maps/1.json
  def destroy
    @group_map.destroy

    respond_to do |format|
      format.html { redirect_to group_maps_url }
      format.json { head :no_content }
    end
  end

  private

  def check_membership
    @group_map = GroupMap.find(params[:id])
    redirect_home unless current_user.is_a_member_of?(@group_map)
  end

  def check_ownership
    @group_map = GroupMap.find(params[:id])
    redirect_home unless @group_map.owner == current_user
  end

  def redirect_home
    redirect_to('/', alert: 'must be logged in')
  end
end
