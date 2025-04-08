class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :bookings
  has_many :meeting_participants
  
  validates :name, :role, :position, presence: true
  
  def admin?
    role == 'admin'
  end
  
  def employee?
    role == 'employee'
  end
  
  def daily_booking_hours(date)
    bookings.where("DATE(start_time) = ?", date.to_date)
            .sum("ROUND((julianday(end_time) - julianday(start_time)) * 24, 1)")
  end
  
  def can_book_more_time?(start_time, end_time)
    new_hours = (end_time - start_time) / 3600
    current_hours = daily_booking_hours(start_time.to_date)
    return (current_hours + new_hours) <= 2
  end
end
