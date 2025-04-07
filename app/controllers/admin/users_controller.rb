class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_user, only: [:edit, :update]
  
  def index
    @users = User.where(role: 'employee')
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :position)
  end
  
  def authorize_admin
    redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
  end
end