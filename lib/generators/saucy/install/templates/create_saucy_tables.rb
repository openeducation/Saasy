class CreateSaucyTables < ActiveRecord::Migration
  def self.up
    create_table :memberships do |table|
      table.integer  :account_id
      table.integer  :user_id
      table.boolean  :admin, :null => false, :default => false
      table.datetime :created_at
      table.datetime :updated_at
    end

    add_index :memberships, [:account_id, :user_id], :unique => true

    create_table :accounts do |table|
      table.belongs_to :plan
      table.string   :name
      table.string   :keyword
      table.datetime :created_at
      table.datetime :updated_at
      table.string   :customer_token
      table.string   :subscription_token
      table.string   :subscription_status
      table.datetime :next_billing_date
      table.boolean  :notified_of_disabling, :default => false, :null => false
      table.boolean  :notified_of_expiration, :default => false, :null => false
      table.boolean  :notified_of_completed_trial, :default => false, :null => false
      table.boolean  :asked_to_activate, :default => false, :null => false
      table.boolean  :activated, :default => false, :null => false
      table.datetime :trial_expires_at
    end
    add_index :accounts, :plan_id
    add_index :accounts, :keyword, :unique => true
    add_index :accounts, :next_billing_date
    add_index :accounts, :created_at
    add_index :accounts, :trial_expires_at

    create_table :invitations do |table|
      table.string   :email
      table.integer  :account_id
      table.integer  :sender_id
      table.boolean  :admin, :null => false, :default => false
      table.string   :code
      table.boolean  :used, :default => false, :null => false
      table.datetime :created_at
      table.datetime :updated_at
    end

    add_index :invitations, [:account_id]

    create_table :permissions do |table|
      table.integer  :membership_id
      table.integer  :user_id
      table.integer  :project_id
      table.datetime :created_at
      table.datetime :updated_at
    end

    add_index :permissions, [:user_id, :project_id]
    add_index :permissions, [:membership_id, :project_id], :name => [:membership_and_project], :unique => true

    create_table :projects do |table|
      table.string   :name
      table.string   :keyword
      table.integer  :account_id
      table.boolean  :archived, :default => false, :null => false
      table.datetime :created_at
      table.datetime :updated_at
    end
    add_index :projects, [:keyword, :account_id], :unique => true
    add_index :projects, :archived

    change_table :users do |table|
      table.string :name, :default => ""
    end

    create_table :plans do |t|
      t.string :name
      t.integer :price, :null => false, :default => 0
      t.boolean :trial, :default => false, :null => false

      t.timestamps
    end

    add_index :plans, :name

    create_table :limits do |t|
      t.belongs_to :plan
      t.string :name
      t.column :value, 'BIGINT UNSIGNED', :null => false, :default => 0
      t.string  :value_type, :null => false, :default => "number"

      t.timestamps
    end

    add_index :limits, :plan_id

    create_table :invitations_projects, :id => false do |table|
      table.integer :invitation_id, :null => false
      table.integer :project_id, :null => false
    end

    add_index :invitations_projects, [:invitation_id, :project_id], :unique => true
  end

  def self.down
    remove_column :users, :name
    drop_table :invitations_projects
    drop_table :plans
    drop_table :projects
    drop_table :permissions
    drop_table :invitations
    drop_table :accounts
    drop_table :memberships
  end
end

