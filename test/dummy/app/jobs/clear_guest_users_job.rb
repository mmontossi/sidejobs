class ClearGuestUsersJob < ApplicationJob
  queue_as :other

  def perform
    User.delete_all
  end

end
