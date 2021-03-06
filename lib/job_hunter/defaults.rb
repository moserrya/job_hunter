module JobHunter
  def run_at(proc)
    @run_at = proc
  end

  def priority(pri)
    @priority = pri
  end

  def queue(queue)
    @queue = queue
  end

  def max_attempts(value)
    define_method(:max_attempts) { value }
  end

  def _defaults_
    { priority: @priority, 
      run_at:   @run_at.try(:call),
      queue:    @queue }.select { |_, v| v }
  end
end
