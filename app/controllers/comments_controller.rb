class CommentsController < ApplicationController
  before_action :logged_in_user

  def create
    @destination = Destination.find(params[:destination_id])
    @user = @destination.user
    @comment = @destination.comments.build(user_id: current_user.id, content: params[:comment][:content])
    if !@destination.nil? && @comment.save
      flash[:success] = "Added a comment!"
    else
      flash[:danger] = "Empty comment can't be posted!"
    end
    redirect_to request.referrer || root_url
  end

  def destroy
  end
end
