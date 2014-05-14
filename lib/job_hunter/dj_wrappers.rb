module JobHunter
  def self.extended(klass)
    klass.include(InstanceMethods)
  end

  def create(*args)
    new_with_options(*args).create
  end

  def find(*args)
    new_with_options(*args).find
  end

  def find_or_create(*args)
    new_with_options(*args).find_or_create
  end

  def destroy(*args)
    new_with_options(*args).destroy
  end

  def new_with_options(*args)
    options = args.extract_options!
    job = new(*args)
    job.define_singleton_method(:_options_) do
      self.class._defaults_.merge(options)
    end
    job
  end

  module InstanceMethods
    def find
      Delayed::Job.where(handler: to_yaml, failed_at: nil).first
    end

    def create
      Delayed::Job.enqueue(self, _options_)
    end

    def find_or_create
      find or create
    end

    def destroy
      find.try(:destroy)
    end

    private
    def _options_
      {}
    end
  end
end
