class SendNewslettersJob < ApplicationJob
  queue_as :newsletters

  def perform
    ActionController::Base.render plain: 'Test'
  end

end
