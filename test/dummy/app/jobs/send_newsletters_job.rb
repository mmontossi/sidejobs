class SendNewslettersJob < ActiveJob::Base
  queue_as :default

  def perform
    puts 'test'
  end

end
