class InvitationMailer < ActionMailer::Base
  def invitation(invitation)
    @invitation = invitation
    subject = I18n.t(:subject,
                     :scope   => [:saucy, :mailers, :invitation_mailer, :invititation],
                     :default => "Invitation")
    mail :to       => invitation.email,
         :subject  => subject,
         :reply_to => invitation.sender_email,
         :from     => sender_name_and_support_address
  end

  private

  def sender_name_and_support_address
    %{"#{@invitation.sender_name}" <#{Saucy::Configuration.support_email_address}>}
  end
end
