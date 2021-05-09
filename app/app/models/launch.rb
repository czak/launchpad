class Launch < ApplicationRecord
  def self.next
    order(:time).first
  end
end
