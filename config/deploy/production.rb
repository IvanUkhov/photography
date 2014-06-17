set :stage, :production

role :web, %w{ivan@ukhov}
server 'ukhov', user: 'ivan', roles: %w{web app}

set :deploy_to, '/home/ivan/projects/photography'
