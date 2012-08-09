class HomeController < ApplicationController
  def index
    @users = User.all
  end

  def test_backboneio
  end
end
