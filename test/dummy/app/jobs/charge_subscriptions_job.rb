class ChargeSubscriptionsJob < ActiveJob::Base
  queue_as :high_priority

  def perform
    puts 'test'
  end

end
