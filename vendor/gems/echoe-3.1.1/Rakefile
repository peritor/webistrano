($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!
require 'echoe'

Echoe.new('echoe') do |p|
  p.project = 'fauna'
  p.author = 'Evan Weaver'
  p.summary = 'A Rubygems packaging tool that provides Rake tasks for documentation, extension compiling, testing, and deployment.'
  p.url = 'http://blog.evanweaver.com/files/doc/fauna/echoe/'
  p.docs_host = 'blog.evanweaver.com:~/www/bax/public/files/doc/'
  p.runtime_dependencies = ['rubyforge >=1.0.2', 'highline']
  p.development_dependencies = []
  p.retain_gemspec = true
  p.require_signed = true
end

