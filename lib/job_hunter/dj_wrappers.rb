module JobHunter
  def create(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    Delayed::Job.enqueue(new(*args), options)
  end
end
