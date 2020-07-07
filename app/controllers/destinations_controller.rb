class DestinationsController < ApplicationController
  before_action :logged_in_user

  def new
    @destination = Destination.new
  end
end
