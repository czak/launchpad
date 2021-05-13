class ApplicationController < ActionController::Base
  before_action do
    @hostname = Socket.gethostname
  end
end
