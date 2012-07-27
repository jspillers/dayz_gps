class GroupMembershipsController < ApplicationController
  # GET /group_memberships
  # GET /group_memberships.json
  def index
    @group_memberships = GroupMembership.all
    @group_map = GroupMap.find(params[:group_map_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_memberships }
    end
  end

  # GET /group_memberships/new
  # GET /group_memberships/new.json
  def new
    @group_membership = GroupMembership.new
    @group_map = GroupMap.find(params[:group_map_id])
    @users = User.all - @group_map.users

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_membership }
    end
  end

  # POST /group_memberships
  # POST /group_memberships.json
  def create
    @group_membership = GroupMembership.new(params[:group_membership])
    @group_map = GroupMap.find(params[:group_map_id])
    @group_membership.group_map = @group_map

    respond_to do |format|
      if @group_membership.save
        format.html { redirect_to(
          group_map_group_memberships_path(@group_map),
          notice: 'Group membership was successfully created.'
        )}
        format.json { render json: @group_membership, status: :created, location: @group_membership }
      else
        format.html { render action: "new" }
        format.json { render json: @group_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_memberships/1
  # DELETE /group_memberships/1.json
  def destroy
    @group_membership = GroupMembership.find(params[:id])
    @group_membership.destroy
    @group_map = GroupMap.find(params[:group_map_id])

    respond_to do |format|
      format.html { redirect_to(
        group_map_group_memberships_path(@group_map),
        notice: 'Group membership was removed.'
      )}
      format.json { head :no_content }
    end
  end
end
