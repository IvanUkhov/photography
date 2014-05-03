class ApplicationController < ActionController::Base
  caches_page :index

  def index
    render file: 'layouts/application'
  end
end
