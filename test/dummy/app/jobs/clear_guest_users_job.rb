class ClearGuestUsersJob < ApplicationJob
  queue_as :other

  def perform
  end

end
