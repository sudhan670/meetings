class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :destroy]
  
  def index
    @bookings = current_user.admin? ? Booking.all : current_user.bookings
  end
  
  def show
  end
  
  def new
    @booking = Booking.new
    @room = Room.find(params[:room_id])
  end
  
  def create
    @booking = current_user.bookings.new(booking_params)
    @booking.status = 'pending'
    
    if @booking.save
      # Add participants
      if params[:participant_ids].present?
        params[:participant_ids].each do |user_id|
          @booking.meeting_participants.create(user_id: user_id, status: 'pending')
        end
      end
      
      redirect_to @booking, notice: 'Booking was successfully created.'
    else
      @room = @booking.room
      render :new
    end
  end
  
  def destroy
    if @booking.can_cancel?
      @booking.update(status: 'canceled')
      redirect_to bookings_path, notice: 'Booking was successfully canceled.'
    else
      redirect_to bookings_path, alert: 'Cannot cancel this booking.'
    end
  end
  
  private
  
  def set_booking
    @booking = Booking.find(params[:id])
  end
  
  def booking_params
    params.require(:booking).permit(:room_id, :start_time, :end_time)
  end
end