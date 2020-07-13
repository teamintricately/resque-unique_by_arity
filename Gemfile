source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'resque-unique_in_queue', github: 'teamintricately/resque-unique_in_queue', ref: 'fdbfe41' # Ensure that only one job per signature can be queued at a time
gem 'resque-unique_at_runtime'

group :test do
  unless ENV['TRAVIS']
    gem 'byebug', '~> 10', platform: :mri, require: false
    gem 'pry', '~> 0', platform: :mri, require: false
    gem 'pry-byebug', '~> 3', platform: :mri, require: false
  end
  gem 'rubocop', '~> 0.60.0'
  gem 'rubocop-rspec', '~> 1.30.0'
  gem 'simplecov', '~> 0', require: false
end

# Specify your gem's dependencies in resque-unique_by_arity.gemspec
gemspec
