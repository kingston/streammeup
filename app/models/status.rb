class Status < ActiveRecord::Base
  attr_accessible :artist, :isLoaded, :isPlaying, :name, :url
end
