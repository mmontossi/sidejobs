class UpdateExchangesJob < ApplicationJob
  queue_as :low_priority

  def perform
  end

end
