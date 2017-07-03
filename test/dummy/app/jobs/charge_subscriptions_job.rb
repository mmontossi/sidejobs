class ChargeSubscriptionsJob < ApplicationJob
  queue_as :high_priority

  def perform
  end

end
