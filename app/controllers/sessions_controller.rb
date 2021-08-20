class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      flash[:success] = "#{user.name} でログインしました"
      redirect_back_or root_url
    else
      flash.now[:danger] = "メールアドレスとパスワードの組み合わせが誤っています"
      render 'new'
    end
  end

  def destroy
    # フラッシュ表示用
    log_out_user = current_user
    log_out if logged_in?
    flash[:danger] = "#{log_out_user.name} からログアウトしました"
    redirect_to root_url
  end
end
