class TeamsController < ApplicationController
  def index
    @teams = Repository.for(:team).all
  end
end
