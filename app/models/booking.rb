class Booking < ApplicationRecord
  belongs_to :room
  belongs_to :user
  has_many :meeting_participants, dependent: :destroy
  
  validates :start_time, :end_time, presence: true
  validates :status, inclusion: { in: ['pending', 'confirmed', 'canceled'] }
  validate :end_time_after_start_time
  validate :booking_in_future
  validate :booking_in_half_hour_slots
  validate :user_daily_limit
  validate :room_availability
  
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :past, -> { where('end_time < ?', Time.current) }
  scope :today, -> { where('DATE(start_time) = ?', Date.today) }
  
  def duration_in_hours
    (end_time - start_time) / 3600.0
  end
  
  def can_cancel?
    start_time > Time.current && status != 'canceled'
  end
  
  private
  
  def end_time_after_start_time
    if start_time >= end_time
      errors.add(:end_time, "must be after start time")
    end
  end
  
  def booking_in_future
    if start_time <= Time.current
      errors.add(:start_time, "must be in the future")
    end
  end
  
  def booking_in_half_hour_slots
    unless start_time.min % 30 == 0 && end_time.min % 30 == 0
      errors.add(:base, "Bookings must be in half-hour slots")
    end
  end
  
  def user_daily_limit
    unless user.can_book_more_time?(start_time, end_time)
      errors.add(:base, "You can only book a maximum of 2 hours per day")
    end
  end
  
  def room_availability
    unless room.available?(start_time, end_time)
      errors.add(:base, "Room is not available during this time slot")
    end
  end
end