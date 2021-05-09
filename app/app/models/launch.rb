class Launch < ApplicationRecord
  def self.next
    where('time > ?', Time.zone.now).order(:time).first
  end
end
