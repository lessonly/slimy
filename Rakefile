require 'bundler'
Bundler::GemHelper.install_tasks
require 'rake/testtask'
require 'bump/tasks'
require 'rubocop/rake_task'


RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end
desc "Run tests"

task default: [:test, :rubocop]