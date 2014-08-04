require 'bundler'
Bundler.require(:default)

module Photography
  class Application < Rail::Application
    config.gems << 'googleplus-reader'

    config.precompile << 'application.css'
    config.precompile << 'main.js'
    config.precompile << 'index.html'
  end
end
