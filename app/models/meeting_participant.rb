class MeetingParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :booking

  # Validations
  validates :status, inclusion: { in: %w[pending accepted rejected missed] }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :missed, -> {where(status: 'missed')}
end