class MeetingParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meeting_participant
  scope :pending, -> { where(status: 'pending') }

  def update
    if @meeting_participant.can_respond?
      if @meeting_participant.update(meeting_participant_params)
        redirect_to bookings_path, notice: 'Meeting response updated successfully.'
      else
        redirect_to bookings_path, alert: 'Failed to update response.'
      end
    else
      redirect_to bookings_path, alert: 'Cannot respond to this meeting anymore.'
    end
  end
  
  private
  
  def set_meeting_participant
    @meeting_participant = current_user.meeting_participants.find(params[:id])
  end
  
  def meeting_participant_params
    params.require(:meeting_participant).permit(:status)
  end
end