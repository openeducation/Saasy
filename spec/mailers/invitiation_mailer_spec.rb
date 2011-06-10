require 'spec_helper'

describe InvitationMailer, "invitation" do
  let(:invitation) { Factory(:invitation) }
  subject { InvitationMailer.invitation(invitation) }

  it "sets reply-to to the user that sent the invitation" do
    subject.reply_to.should == [invitation.sender_email]
  end

  it "sets from to the user's name" do
    from = subject.header_fields.detect { |field| field.name == "From"}
    from.value.should =~ %r{^"#{invitation.sender_name}" <.*>$}
  end

  it "sends from the support address" do
    subject.from.should == [Saucy::Configuration.support_email_address]
  end
end
