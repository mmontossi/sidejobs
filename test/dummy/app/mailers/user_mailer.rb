class UserMailer < ApplicationMailer

  def invite(recipient)
    mail from: 'test@mail.com', to: recipient
  end

end
