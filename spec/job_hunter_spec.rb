require 'spec_helper'
require 'pry'

class KustomJob < Struct.new(:model_id, :details)
  extend JobHunter

  def perform
  end
end

describe JobHunter do
  let(:model_id) { 47 }
  let(:details)  { 'Party Solver' }
  let(:run_at)   { DateTime.parse('January 28, 2015 0800') }
  let(:options)  { { run_at: run_at } }

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
end
