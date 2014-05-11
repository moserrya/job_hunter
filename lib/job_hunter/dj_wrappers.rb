module JobHunter
  def create(*args)
    options = args.extract_options!
    Delayed::Job.enqueue(new(*args), _defaults_.merge(options))
  end

  def find(*args)
    handler = new(*args).to_yaml
    Delayed::Job.where(handler: handler).first
  end

  def find_or_create(*args)
    options = args.extract_options!
    find(*args) or create(*[args, options])
  end

  def destroy(*args)
    find(*args).try(:destroy)
  end
end
