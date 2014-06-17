require 'haml'
require 'uglifier'
require 'sprockets'

Haml::Options.defaults[:ugly] = true if ENV['production']
Sprockets.register_engine('.haml', Tilt::HamlTemplate)

class Application
  def call(env)
    case env['PATH_INFO']
    when '/'
      pipeline = build_pipeline(env)
      [ 200, {}, [ pipeline['application.html'].to_s ] ]
    when /^.+(js|css)$/
      pipeline = build_pipeline(env)
      pipeline.call(env)
    else
      browser.call(env)
    end
  end

  private

  def browser
    @browser ||= Rack::Directory.new('public')
  end

  def build_pipeline(env)
    pipeline = Sprockets::Environment.new

    pipeline.append_path(gem_assets_path('googleplus-reader', 'javascripts'))
    pipeline.append_path('app/assets/javascripts')
    pipeline.append_path('app/assets/stylesheets')
    pipeline.append_path('app/views/layouts')

    if ENV['production']
      pipeline.js_compressor = :uglifier
      pipeline.css_compressor = :scss
    end

    pipeline
  end

  def gem_assets_path(name, *path)
    gem = Gem::Specification.find_by_name(name)
    File.join(gem.gem_dir, 'lib', 'assets', *path)
  end
end
