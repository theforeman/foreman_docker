namespace :test do
  desc "Test ForemanDocker"
  Rake::TestTask.new(:docker) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = false
    t.warning = false
  end
end

namespace :docker do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_docker) do |task|
        task.patterns = ["#{ForemanDocker::Engine.root}/app/**/*.rb",
                         "#{ForemanDocker::Engine.root}/lib/**/*.rb",
                         "#{ForemanDocker::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts "Rubocop not loaded."
    end

    Rake::Task['rubocop_docker'].invoke
  end
end

Rake::Task[:test].enhance ['test:docker']

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task["jenkins:unit"].enhance ['test:docker',
                                      'docker:rubocop']
end
