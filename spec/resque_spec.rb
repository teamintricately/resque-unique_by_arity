require 'spec_helper'

RSpec.describe 'Resque overview' do
  before do
    Resque.redis.del(Resque.redis.keys)
  end

  it 'enqueues jobs' do
    Resque.enqueue UniqueFakeJobWithArity, 'foo'

    expect(Resque.enqueued?(UniqueFakeJobWithArity, 'foo')).to eq true
  end

  it 'enqueues the same job with different argument' do
    Resque.enqueue UniqueFakeJobWithArity, 'foo'
    Resque.enqueue UniqueFakeJobWithArity, 'bar'

    expect(Resque.enqueued?(UniqueFakeJobWithArity, 'foo')).to eq true
    expect(Resque.enqueued?(UniqueFakeJobWithArity, 'bar')).to eq true

    queue = UniqueFakeJobWithArity.instance_variable_get(:@queue)

    expect(Resque.size(queue)).to eq 2
  end

  it 'marks the job as unqueued after it runs' do
    Resque.enqueue UniqueFakeJobWithArity, 'foo'

    job = Resque.reserve(UniqueFakeJobWithArity.instance_variable_get(:@queue))
    job.perform

    expect(Resque.enqueued?(UniqueFakeJobWithArity, 'foo')).to eq false
  end

  it 'locks the queue when the job takes too long to run' do
    queue = UniqueSlowFakeJobWithArity.instance_variable_get(:@queue)

    Resque.enqueue UniqueSlowFakeJobWithArity, 'foo'

    thread = Thread.new do
      job, args = Resque.reserve(queue)
      job.perform(*args)
    end

    expect(UniqueSlowFakeJobWithArity.queue_locked?('foo')).to be_truthy
    expect(UniqueSlowFakeJobWithArity.queue_locked?('bar')).to be_falsey

    expect(Resque.size(queue)).to eq 0

    thread.join

    Resque.enqueue UniqueSlowFakeJobWithArity, 'foo'

    expect(Resque.size(queue)).to eq 1
  end
end
