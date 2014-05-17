module JobHunter
  def self.extended(base_class)
    base_class.include(InstanceMethods)
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

    def extend_or_create
      if job = find
        if run_at = self.class._defaults_[:run_at]
          job.update_attributes run_at: run_at
        end
      else
        create
      end
    end

    private
    def _options_
      {}
    end
  end

  InstanceMethods.public_instance_methods.each do |method_sym|
    define_method(method_sym) do |*args|
      new_with_options(*args).send method_sym
    end
  end

  def new_with_options(*args)
    options = args.extract_options!
    job = new(*args)
    job.define_singleton_method(:_options_) do
      self.class._defaults_.merge(options)
    end
    job
  end
end
