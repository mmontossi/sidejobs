class ShareProductsJob < ApplicationJob
  queue_as :default

  def perform
    raise 'Unavailable'
  end

end
