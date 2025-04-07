class Room < ApplicationRecord
  has_many :bookings

  validates :name, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  def available?(start_time, end_time)
    overlapping_bookings = bookings.where("(start_time <= ? AND end_time > ?) OR (start_time < ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)", 
                                         end_time, start_time, end_time, start_time, start_time, end_time)
    overlapping_bookings.empty?
  end

  # New class method to fetch available rooms
  def self.available(start_time, end_time)
    all.select { |room| room.available?(start_time, end_time) }
  end
end
