# add a test:non_transactional task that executes all tests in test/non_transactional/*_test.rb
namespace :test do

  Rake::TestTask.new(:non_transactional) do |t|
    t.pattern = 'test/non_transactional/*_test.rb'
    t.ruby_opts << '-rubygems'
    t.verbose = true
  end

end

