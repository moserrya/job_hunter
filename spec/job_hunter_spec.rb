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
  let(:options)  { {run_at: 5.hours.from_now} }

  context '#create' do
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

  context '#find' do
    before do
      custom_job = KustomJob.new model_id, details
      @job = Delayed::Job.enqueue custom_job
    end

    it 'finds the job given the same arguments' do
      expect(KustomJob.find(model_id, details)).to eq(@job)
    end
  end
end
