set :application, 'ukhov'
set :repo_url, 'gitolite@ukhov.me:web/ukhov.git'

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :finishing, 'deploy:cleanup'
  after :finishing, 'restart'
end
