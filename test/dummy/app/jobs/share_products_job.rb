class ShareProductsJob < ActiveJob::Base
  queue_as :default

  def perform
    raise 'Social network unavailable'
  end

end
