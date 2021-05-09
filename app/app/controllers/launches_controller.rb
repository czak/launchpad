class LaunchesController < ApplicationController
  def next
    @launch = Launch.next
  end
end
