class DestinationsController < ApplicationController
  before_action :logged_in_user

  def new
    @destination = Destination.new
  end

  def create
    @destination = current_user.destinations.build(destination_params)
    if @destination.save
      flash[:success] = "Destination added!"
      redirect_to root_url
    else
      render 'destinations/new'
    end
  end

  private

  def destination_params
    params.require(:destination).permit(:name, :discription, :country)
  end
end
