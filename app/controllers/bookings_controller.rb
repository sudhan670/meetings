class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show]
  before_action :set_room, only: [:new, :create, :show]

  def index
    @bookings = current_user.bookings.includes(:room)
    @invitations = current_user.meeting_participants.pending.includes(booking: [:room, :user]).order('bookings.start_time')
  end
  
  def new
    @booking = @room.bookings.build
  end

  def show
    @meeting_participants = @booking.meeting_participants.includes(:user)
  end

  def create
    @booking = @room.bookings.build(booking_params)
    @booking.user = current_user

    if @booking.save
      # Create meeting participants using participant_ids from form
      if params[:participant_ids].present?
        params[:participant_ids].each do |user_id|
          user = User.find(user_id)
          MeetingParticipant.create(
            user: user,
            booking: @booking,
            status: 'pending'
          )
        end
      end

      # Always create a meeting participant for the booking creator
      MeetingParticipant.create(
        user: current_user,
        booking: @booking,
        status: 'accepted'
      )

      redirect_to room_booking_path(@room, @booking), notice: 'Booking was successfully created.'
    else
      render :new
    end
  end

  private

  def set_room
    @room = if params[:room_id]
              Room.find(params[:room_id])
            elsif @booking
              @booking.room
            end
  
    redirect_to rooms_path, alert: "Room not found" unless @room
  end
  
  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:room_id, :start_time, :end_time)
  end
end