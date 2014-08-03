require_relative 'config/application'

Photography::Application.load_tasks

task :default do
  Photography::Application.config.compress = true
  Rake::Task['assets'].execute
end
