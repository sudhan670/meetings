class MeetingParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meeting_participant

  def update
    respond_to do |format|
      if @meeting_participant.update(meeting_participant_params)
        format.html { 
          redirect_to bookings_path, 
          notice: "Invitation #{@meeting_participant.status} successfully." 
        }
        format.json { render :show, status: :ok }
      else
        format.html { 
          redirect_to bookings_path, 
          alert: 'Unable to update invitation status.' 
        }
        format.json { 
          render json: @meeting_participant.errors, 
          status: :unprocessable_entity 
        }
      end
    end
  end

  private

  def set_meeting_participant
    @meeting_participant = current_user.meeting_participants.pending.find(params[:id])
  end

  def meeting_participant_params
    params.require(:meeting_participant).permit(:status)
  end
end