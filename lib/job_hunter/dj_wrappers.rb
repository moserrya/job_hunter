module JobHunter
  def create(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    Delayed::Job.enqueue(new(*args), options)
  end

  def find(*args)
    handler = new(*args).to_yaml
    Delayed::Job.where(handler: handler).first
  end
end
