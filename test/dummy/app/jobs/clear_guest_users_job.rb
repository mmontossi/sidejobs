class ClearGuestUsersJob < ActiveJob::Base
  queue_as :other

  def perform
    puts 'test'
  end

end
