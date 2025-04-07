require "test_helper"

class MeetingParticipantsControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get meeting_participants_update_url
    assert_response :success
  end
end
