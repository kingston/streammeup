class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login

  private

  def require_login
    unless session[:authenticated]
      redirect_to "/"
    end
  end
end
