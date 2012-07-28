class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_ownership, only: [:show]

  def index
    @users = User.all
  end

  def show
  end

  private

  def check_ownership
    @user = User.find(params[:id])
    @owner = true if current_user == @user
  end
end
