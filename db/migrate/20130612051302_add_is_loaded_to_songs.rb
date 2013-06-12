class AddIsLoadedToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :isLoaded, :boolean
  end
end
