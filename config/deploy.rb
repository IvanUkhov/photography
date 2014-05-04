set :application, 'photography'
set :repo_url, 'gitolite@ukhov.me:web/photography.git'
set :keep_releases, 2

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:all), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :cleanup
  after :publishing, :restart
end
