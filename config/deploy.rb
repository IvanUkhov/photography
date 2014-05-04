set :application, 'photography'
set :repo_url, 'gitolite@ukhov.me:web/photography.git'

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
end

after :deploy, 'deploy:cleanup'
after :deploy, 'deploy:restart'
