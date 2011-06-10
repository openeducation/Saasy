class BillingMailer < ActionMailer::Base
  def receipt(account, transaction)
    @account = account
    @transaction = transaction
    mail(:to       => account.customer.email,
         :subject  => I18n.t(:subject,
                             :scope   => [:saucy, :mailers, :billing_mailer, :receipt],
                             :default => "Subscription receipt"),
         :reply_to => Saucy::Configuration.support_email_address,
         :from     => Saucy::Configuration.support_email_address)
  end

  def problem(account, transaction)
    @account = account
    mail(:to       => account.customer.email,
         :subject  => I18n.t(:subject,
                             :scope   => [:saucy, :mailers, :billing_mailer, :problem],
                             :default => "Problem with subscription billing"),
         :reply_to => Saucy::Configuration.support_email_address,
         :from     => Saucy::Configuration.support_email_address)
  end

  def expiring_trial(account)
    @account = account
    mail(:to       => account.admin_emails,
         :subject  => I18n.t(:subject,
                            :scope   => [:billing_mailer, :expiring_trial],
                            :default => "Your trial is expiring soon"),
         :reply_to => Saucy::Configuration.support_email_address,
         :from     => Saucy::Configuration.manager_email_address)
  end

  def new_unactivated(account)
    @account = account
    mail(:to       => account.admin_emails,
         :subject  => I18n.t(:subject,
                            :scope    => [:billing_mailer, :new_unactivated],
                            :default  => "A check in from %{app_name}",
                            :app_name => t("app_name")),
         :reply_to => Saucy::Configuration.support_email_address,
         :from     => Saucy::Configuration.manager_email_address)
  end

  def completed_trial(account)
    @account = account
    mail(:to       => account.admin_emails,
         :subject  => I18n.t(:subject,
                            :scope   => [:billing_mailer, :completed_trial],
                            :default => "Your trial has ended"),
         :reply_to => Saucy::Configuration.support_email_address,
         :from     => Saucy::Configuration.manager_email_address)
  end
end
