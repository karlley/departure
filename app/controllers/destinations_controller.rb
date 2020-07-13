class DestinationsController < ApplicationController
  before_action :logged_in_user

  def show
    @destination = Destination.find(params[:id])
  end

  def new
    @destination = Destination.new
  end

  def create
    @destination = current_user.destinations.build(destination_params)
    if @destination.save
      flash[:success] = "Destination added!"
      redirect_to destination_path(@destination)
    else
      render 'destinations/new'
    end
  end

  def edit
    @destination = Destination.find(params[:id])
  end

  def update
    @destination = Destination.find(params[:id])
    if @destination.update_attributes(destination_params)
      flash[:success] = "Destination updated!"
      redirect_to @destination
    else
      render 'edit'
    end
  end

  private

  def destination_params
    params.require(:destination).permit(:name, :description, :country)
  end
end
