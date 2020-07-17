class UniqueSlowFakeJobWithArity
  @queue = :normal

  def self.perform(_req, _opts = {})
    sleep 0.1
  end

  include Resque::Plugins::UniqueByArity.new(
    arity_for_uniqueness: 1,
    unique_at_runtime: true,
    unique_in_queue: true
  )
end
