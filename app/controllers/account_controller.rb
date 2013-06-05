require 'bcrypt'

class AccountController < ApplicationController
  include BCrypt
  skip_before_filter :require_login, :only => [:login, :logout]

  def login
    password = Password.new(Settings.app_password)
    if password == params[:password]
      session[:authenticated] = true
      redirect_to "/home"
    else
      redirect_to "/"
    end
  end

  def logout
    session[:authenticated] = false
    redirect_to "/"
  end
end
