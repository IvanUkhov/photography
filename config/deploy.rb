set :application, 'ukhov'
set :repository,  'gitolite@ukhov.me:web/ukhov.git'

set :scm, :git

set :user, 'ivan'
set :use_sudo, false
set :deploy_to, "/home/#{ user }/projects/site"

server 'ukhov', :app, :web, :db, :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{ File.join current_path, 'tmp', 'restart.txt' }"
  end
end

set :gems, '/usr/local/rvm/gems/ruby-1.9.3-p327'
set :rubies, '/usr/local/rvm/rubies/ruby-1.9.3-p327'

after 'deploy:update_code' do
  run "cd #{ release_path} && export PATH=$PATH:#{ gems }/bin:#{ rubies}/bin && export GEM_PATH=#{ gems }:#{ gems }@global && export GEM_HOME=#{ gems } && #{ gems }/bin/rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile"
end
