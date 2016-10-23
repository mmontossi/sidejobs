class UpdateExchangesJob < ActiveJob::Base
  queue_as :low_priority

  def perform
    puts 'test'
  end

end
