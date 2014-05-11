module JobHunter
  def create(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    Delayed::Job.enqueue(new(*args), options)
  end

  def find(*args)
    handler = new(*args).to_yaml
    Delayed::Job.where(handler: handler).first
  end

  def find_or_create(*args)
    job_args = args.last.is_a?(Hash) ? args[0..-2] : args
    find(*job_args) or create(*args)
  end
end
