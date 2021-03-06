JobHunter
==========

JobHunter is a library that cuts down on boilerplate when creating and finding [Delayed::Job](https://github.com/collectiveidea/delayed_job) custom jobs. It replaces this:

```ruby
Delayed::Job.enqueue(MyCustomJob.new(data, other_data), priority: 100, run_at: 5.hours.from_now)
```

With this:

```ruby
MyCustomJob.create(data, other_data)
```


Installation
-------

JobHunter supports DelayedJob 3.0+ with ActiveRecord as the backend. Just add `job_hunter` to your `Gemfile`.

Usage
-------

Add `extend JobHunter` at the top of a class you plan to use as a custom job. After this line, you can set defaults for this job with `run_at`, `priority`, `queue`, and `max_attempts`:


```ruby
class KustomJob < Struct.new(:model_id, :details)
  extend JobHunter
  
  run_at -> { 24.hours.from.now }
  priority 37
  queue :sugar_glider
  max_attempts 4

  def perform
    # do amazing things
  end
end
```

`run_at` accepts a Proc object. The value is evaluated when you enqueue a new custom job.

JobHunter also provides class methods to find, create, and destroy jobs:

```ruby
model_id = 22
details  = "You seem to a have a squid on your head."

KustomJob.create(model_id, details)

KustomJob.find(model_id, details)

KustomJob.find_or_create(model_id, details)

KustomJob.delete(model_id, details)
  
```

Adding an index to `handler` in the `delayed_jobs` table is recommended if you plan on making regular use of `find` or `find_or_create`.

All of these methods will return a `Delayed::Job` if they find, create, or destroy a job and `nil` otherwise.

`find` will not return failed jobs (all attempts exhausted). `find_or_create` will likewise create a new job if there is an identical failed job.

The `create` and `find_or_create` methods accept the same options hash as `Delayed::Job.enqueue`. Options passed in to these methods (`run_at`, `queue`, and `priority`) will override the defauls set in your custom job class. Options passed in to `find_or_create` will not affect a job already enqueued.

These class methods have corresponding instance methods:

```ruby
model_id = 22
details  = "You seem to a have a squid on your head."

custom_job = KustomJob.new model_id, details

job.find

job.create

job.find_or_create

job.delete
```

Unlike the identically named class methods, `#create` and `#find_or_create` do not take an options hash. However, you can still override defaults by initializing your class by using `new_with_options`:

```ruby
super_custom_job = KustomJob.new_with_options model_id, details, run_at: 12.minutes.from.now

super_custom_job.create
```

