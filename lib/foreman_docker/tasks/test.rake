require File.expand_path("../engine", File.dirname(__FILE__))
namespace :test do
   namespace :docker do

    desc "Run the plugin unit test suite."
    task :test => ['db:test:prepare'] do
      test_task = Rake::TestTask.new('docker_test_task') do |t|
        t.libs << ["test", "#{ForemanDocker::Engine.root}/test"]
        t.test_files = [
          "#{ForemanDocker::Engine.root}/test/**/*_test.rb",
        ]
        t.verbose = true
      end

      Rake::Task[test_task.name].invoke
    end
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:docker'].invoke
end
