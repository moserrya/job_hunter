require 'rspec'

require 'active_support/dependencies'
require 'active_record'

require 'delayed_job_active_record'

require 'job_hunter'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :delayed_jobs, :force => true do |table|
    table.integer  :priority, :default => 0
    table.integer  :attempts, :default => 0
    table.text     :handler
    table.text     :last_error
    table.datetime :run_at
    table.datetime :locked_at
    table.datetime :failed_at
    table.string   :locked_by
    table.string   :queue
    table.timestamps
  end

  add_index :delayed_jobs, [:priority, :run_at], name: 'delayed_jobs_priority'
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:each) do
    Delayed::Job.delete_all
  end
end
