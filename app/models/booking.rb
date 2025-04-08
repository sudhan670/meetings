class Booking < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :room
  has_many :meeting_participants, dependent: :destroy
  has_many :participants, through: :meeting_participants, source: :user

  # Enums
  enum :status,{
    pending: 0, 
    confirmed: 1, 
    canceled: 2, 
    rejected: 3
  }

  # Validations
  validates :start_time, :end_time, presence: true
  validate :start_time_must_be_at_hour_or_half_hour
  validate :end_time_must_be_at_hour_or_half_hour
  validate :booking_duration
  validate :no_overlapping_bookings
  validate :daily_booking_limit

  # Scopes
  scope :past, -> { where('start_time < ?', Time.current) }
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :current, -> { where('start_time <= ? AND end_time >= ?', Time.current, Time.current) }
  scope :recent_first, -> { order(start_time: :desc) }
  scope :oldest_first, -> { order(start_time: :asc) }

  # Class Methods
  class << self
    def available_slots(room, date)
      # Find available time slots for a specific room and date
      booked_slots = room.bookings.where('DATE(start_time) = ?', date)
      
      # Define working hours (e.g., 9 AM to 5 PM)
      working_hours = (9..17).map do |hour|
        [
          Time.zone.local(date.year, date.month, date.day, hour, 0),
          Time.zone.local(date.year, date.month, date.day, hour, 30)
        ]
      end.flatten

      working_hours.reject do |slot|
        booked_slots.any? do |booking|
          slot >= booking.start_time && slot < booking.end_time
        end
      end
    end
  end

  scope :missed, -> {
    where(
      "status = 'confirmed' AND start_time < ?", 
      Time.current
    ).left_joins(:meeting_participants)
    .where(
      "meeting_participants.status IS NULL OR meeting_participants.status != 'attended'"
    )
  }

  # Method to determine if a booking is missed
  def missed?
    status == 'confirmed' && 
    start_time < Time.current && 
    meeting_participants.none? { |mp| mp.status == 'attended' }
  end

  # Optional: Add a reason for missed meeting
  def missed_reason
    # This could be a custom field or logic to determine why a meeting was missed
    # For example:
    read_attribute(:missed_reason) || 
    (no_participants? ? "No participants" : nil)
  end
  def can_cancel?
    # Can cancel if:
    # 1. Booking is in the future
    # 2. Status is not already cancelled
    # 3. Booking is not too close to start time
    in_future? && 
      !canceled? && 
      start_time > (Time.current + 1.hour)
  end
  private

  def no_participants?
    meeting_participants.empty?
  end

  # Instance Methods
  def duration_in_hours
    return 0 if start_time.nil? || end_time.nil?
    
    # Calculate duration in hours and round to 2 decimal places
    ((end_time - start_time) / 1.hour).round(2)
  end

  def in_future?
    start_time > Time.current.in_time_zone
  end



  def participant_status
    # Determine overall participant status
    statuses = meeting_participants.pluck(:status)
    
    return :pending if statuses.include?('pending')
    return :rejected if statuses.include?('rejected')
    return :accepted if statuses.all? { |status| status == 'accepted' }
    
    :unknown
  end

  private

  def start_time_must_be_at_hour_or_half_hour
    return if start_time.nil?
    
    unless [0, 30].include?(start_time.min)
      errors.add(:start_time, "must be at the hour or half-hour")
    end
  end

  def end_time_must_be_at_hour_or_half_hour
    return if end_time.nil?
    
    unless [0, 30].include?(end_time.min)
      errors.add(:end_time, "must be at the hour or half-hour")
    end
  end

  def booking_duration
    return if start_time.nil? || end_time.nil?
    
    if (end_time - start_time) > 2.hours
      errors.add(:base, "Booking cannot be longer than 2 hours")
    end

    if (end_time - start_time) <= 0
      errors.add(:base, "End time must be after start time")
    end
  end

  def no_overlapping_bookings
    return if room.nil? || start_time.nil? || end_time.nil?

    overlapping_bookings = room.bookings.where.not(id: id).where(
      "(start_time < ? AND end_time > ?) OR " \
      "(start_time >= ? AND start_time < ?) OR " \
      "(end_time > ? AND end_time <= ?)",
      end_time, start_time,
      start_time, end_time,
      start_time, end_time
    )

    if overlapping_bookings.exists?
      errors.add(:base, "Room is already booked for the selected time")
    end
  end

  def daily_booking_limit
    return if user.nil? || start_time.nil?

    # Calculate total booking hours for the user on this day
    daily_bookings = user.bookings.where(
      "DATE(start_time) = ?", 
      start_time.to_date
    )

    total_booking_hours = daily_bookings.sum { |b| (b.end_time - b.start_time) / 1.hour }
    new_booking_hours = (end_time - start_time) / 1.hour

    if total_booking_hours + new_booking_hours > 2
      errors.add(:base, "Cannot book more than 2 hours per day")
    end
  end
end