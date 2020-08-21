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
    # 遷移前のurl を取得
    redirect_to request.referrer || root_url
  end

  def destroy
    @comment = Comment.find(params[:id])
    @destination = @comment.destination
    if current_user.id == @comment.user_id
      @comment.destroy
      flash[:success] = "Deleted a comment!"
    end
    redirect_to destination_url(@destination)
  end
end
