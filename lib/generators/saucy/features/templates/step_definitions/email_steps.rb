When /^I follow the link sent to "([^"]+)"$/ do |email_address|
  email = ActionMailer::Base.deliveries.detect do |tmail|
    tmail.to.include?(email_address)
  end or raise "No email sent to #{email_address}"

  unless match = email.body.match(%r{http://\S+})
    raise "No link included in the email:\n#{email.body}"
  end
  url = match[0]

  visit url
end

When /^I follow the link sent to "([^"]+)" with subject "([^"]+)"$/ do |email_address, subject|
  to_address = ActionMailer::Base.deliveries.select do |tmail|
    tmail.to.include?(email_address)
  end or raise "No email sent to #{email_address}"

  email = to_address.detect do |tmail|
    tmail.subject.include?(subject)
  end or raise "No email sent to #{email_address} with subject #{subject}"

  unless match = email.body.match(%r{http://\S+})
    raise "No link included in the email:\n#{email.body}"
  end
  url = match[0]

  visit url
end

Then /^an email with subject "([^"]*)" should be sent to "([^"]*)"$/ do |subject, to_address|
  email = ActionMailer::Base.deliveries.detect do |tmail|
    tmail.subject.include?(subject)
  end or raise "No email with subject #{subject}"

  unless email.to.include?(to_address)
    raise "No email sent to #{to_address}"
  end
end

