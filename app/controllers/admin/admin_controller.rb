module Admin
  class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin
    
    def dashboard
      @rooms = Room.all
      @bookings = Booking.all
      @today_bookings = Booking.today
      @users = User.where(role: 'employee')
    end
    
    private
    
    def authorize_admin
      redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
    end
  end
end