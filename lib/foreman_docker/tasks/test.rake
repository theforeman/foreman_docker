require File.expand_path("../engine", File.dirname(__FILE__))
namespace :test do
  desc "Run the plugin unit test suite."
  task :docker => ['db:test:prepare'] do
    test_task = Rake::TestTask.new('docker_test_task') do |t|
      t.libs << ["test", "#{ForemanDocker::Engine.root}/test"]
      t.test_files = [
        "#{ForemanDocker::Engine.root}/test/**/*_test.rb"
      ]
      t.verbose = true
    end

    Rake::Task[test_task.name].invoke
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:docker'].invoke
end

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task["jenkins:unit"].enhance do
    Rake::Task['test:docker'].invoke
  end
end
