set :stage, :production

role :web, %w{ivan@ukhov}
server 'ukhov', user: 'ivan', roles: %w{web app}

set :deploy_to, '/home/ivan/projects/site'

set :default_env, {
  GEM_HOME: '/usr/local/rvm/gems/ruby-2.1.0',
  GEM_PATH: '/usr/local/rvm/gems/ruby-2.1.0:/usr/local/rvm/gems/ruby-2.1.0@global',
  PATH: "/usr/local/rvm/rubies/ruby-2.1.0/bin:/usr/local/rvm/gems/ruby-2.1.0/bin:$PATH"
}
