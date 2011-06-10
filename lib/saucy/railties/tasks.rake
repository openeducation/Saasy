namespace :saucy do
  desc "Updates subscription status and delivers receipt/problem notices"
  task :update_subscriptions => :environment do
    Account.update_subscriptions!
  end

  desc "Deliver notifications for users that have signed up and aren't activated"
  task :ask_users_to_activate => :environment do
    Account.deliver_new_unactivated_notifications
  end

  desc "Deliver notifications to users with expiring trial accounts"
  task :deliver_expiring_trial_notifications => :environment do
    Account.deliver_expiring_trial_notifications
  end

  desc "Deliver notifications to users with completed trial accounts"
  task :deliver_completed_trial_notifications => :environment do
    Account.deliver_completed_trial_notifications
  end

  desc "Run all daily tasks"
  task :daily => [:update_subscriptions,
                  :ask_users_to_activate,
                  :deliver_expiring_trial_notifications,
                  :deliver_completed_trial_notifications]
end

