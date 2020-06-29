class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update]
  before_action :correct_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to Departure!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def index
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params_update)
      flash[:success] = "Your Profile has been updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  # ユーザー新規作成時に許可する属性
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # プロフィール編集時に許可する属性
  def user_params_update
    params.require(:user).permit(:name, :email, :introduction, :nationality)
  end

  # 正しいユーザーか確認
  def correct_user
    @user = User.find(params[:id])
    if !current_user?(@user)
      flash[:danger] = "このページはアクセスできません"
      redirect_to(root_url)
    end
  end
end
