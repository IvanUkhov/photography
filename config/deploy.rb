set :application, 'photography'
set :repo_url, 'gitolite@ukhov.me:web/photography.git'
set :keep_releases, 2

namespace :deploy do
  desc 'Restart application'
  task :assets do
    on roles(:all) do
      execute(:rake, 'assets:precompile')
    end
  end

  after :publishing, :cleanup
  after :publishing, :restart
end
