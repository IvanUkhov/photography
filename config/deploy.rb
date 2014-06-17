set :application, 'photography'
set :repo_url, 'gitolite@ukhov.me:web/photography.git'
set :keep_releases, 2

namespace :deploy do
  desc 'Precompile static files'
  task :assets do
    on roles(:all) do
      execute "cd '#{ release_path }'; bundle exec rake assets:precompile"
    end
  end

  after :publishing, :cleanup
  after :publishing, :assets
end
