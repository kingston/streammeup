class PublicController < ApplicationController
  skip_before_filter :require_login, :only => [ :index ]

  def index
    render :layout => 'public'
  end
end
