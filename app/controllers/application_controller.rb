class ApplicationController < ActionController::Base
  def index
    render nothing: true, layout: 'application'
  end
end
