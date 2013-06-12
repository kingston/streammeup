class Song < ActiveRecord::Base
  attr_accessible :artist, :name, :url
end
