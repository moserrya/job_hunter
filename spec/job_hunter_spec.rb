require 'spec_helper'

class KustomJob < Struct.new(:model_id, :details)
  extend JobHunter

  def perform
  end

  def self.remove_method(sym)
    define_method(name) { super }
  end
end

describe JobHunter do
  let(:model_id) { 47 }
  let(:details)  { 'Party Solver' }
  let(:options)  { { priority: 7 } }

  context '.create' do
    it 'enqueues Delayed Jobs' do
      expect {
        KustomJob.create model_id, details
      }.to change{Delayed::Job.count}.by(1)
    end

    it 'happily creates identical jobs' do
      expect {
        3.times { KustomJob.create model_id, details }
      }.to change{Delayed::Job.count}.by(3)
    end

    it 'works with an options hash' do
      expect {
        KustomJob.create model_id, details, options
      }.to change{Delayed::Job.count}.by(1)
    end
  end

  context '.find' do
    before do
      custom_job = KustomJob.new model_id, details
      @job = Delayed::Job.enqueue custom_job
    end

    it 'finds the job given the same arguments' do
      expect(KustomJob.find(model_id, details)).to eq(@job)
    end

    it 'does not find failed jobs' do
      @job.touch(:failed_at)
      expect(KustomJob.find(model_id, details)).to be_nil
    end
  end

  context '.find_or_create' do
    it 'creates the job when it is not in the queue' do
      expect {
        KustomJob.find_or_create model_id, details, options
      }.to change{Delayed::Job.count}.by(1)
    end

    context 'job already enqueued' do
      before do 
        @job = KustomJob.create model_id, details
      end

      it 'does not enqueue a job if one with the same arguments was already enqueued' do
        expect {
          KustomJob.find_or_create model_id, details, options
        }.not_to change{Delayed::Job.count}
      end

      it 'returns the job if it was already enqueued' do
        expect(KustomJob.find_or_create model_id, details, options).to eq(@job)
      end
    end
  end

  context '.destroy' do
    it 'destroys the job, removing it from the queue' do
      KustomJob.create model_id, details
      expect {
        KustomJob.destroy model_id, details
      }.to change{Delayed::Job.count}.by(-1)
    end

    it 'returns nil if there is nothing to destory' do
      expect(KustomJob.destroy model_id, details).to be_nil
    end
  end

  context '.max_attempts' do
    let(:attempts) { 3 }

    it 'sets max attempts in an instance method of the same name' do
      kustom_job = KustomJob.new
      expect {
        KustomJob.max_attempts attempts
      }.to change{kustom_job.try(:max_attempts)}.from(nil).to(attempts)
    end

    after do
      KustomJob.remove_method :max_attempts
    end
  end

  context '.run_at' do
    let(:default_time) { -> { DateTime.parse('April 23, 2015 07:23') } }
    let(:override) { 6.hours.from_now }

    before do
      KustomJob.run_at default_time
    end

    it 'gives jobs the default run_at time' do
      job = KustomJob.create
      expect(job.run_at).to eq(default_time.call)
    end

    it 'allows overriding the default time' do
      job = KustomJob.create run_at: override
      expect(job.run_at).to eq(override)
    end
  end

  context '.priority' do
    let(:default_priority) { 37 }
    let(:override) { 13 }

    before do
      KustomJob.priority default_priority
    end

    it 'gives jobs the default priority' do
      job = KustomJob.create
      expect(job.priority).to eq(default_priority)
    end

    it 'allows overriding the default priority' do
      job = KustomJob.create priority: override
      expect(job.priority).to eq(override)
    end
  end

  context '.queue' do
    let(:default_queue) { 'sugar_glider' }
    let(:override) { 'sugar_moo' }

    before do
      KustomJob.queue default_queue
    end

    it 'gives jobs the default queue' do
      job = KustomJob.create
      expect(job.queue).to eq(default_queue)
    end

    it 'allows overriding the default queue' do
      job = KustomJob.create queue: override
      expect(job.queue).to eq(override)
    end
  end
end
