class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :name
      t.string :artist
      t.string :url
      t.boolean :isPlaying
      t.boolean :isLoaded

      t.timestamps
    end
  end
end
