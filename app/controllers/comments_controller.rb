class CommentsController < ApplicationController
  before_action :logged_in_user

  def create
    @destination = Destination.find(params[:destination_id])
    @user = @destination.user
    @comment = @destination.comments.build(user_id: current_user.id, content: params[:comment][:content])
    if !@destination.nil? && @comment.save
      flash[:success] = "Added a comment!"
      # 自分以外のユーザーからコメントが発生すると通知を作成
      if @user != current_user
        # コメントのtype 種別は2
        @user.notifications.create(destination_id: @destination.id, type: 2, from_user_id: current_user.id, content: @comment.content)
        @user.update_attribute(:notification, true)
      end
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
