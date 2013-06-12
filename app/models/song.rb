require 'player_control'
require 'uri'

class Song < ActiveRecord::Base
  attr_accessible :artist, :name, :url, :isLoaded

  def process(hostUrl)
    system("echo \"Processing #{self.url}...\" >> delayed.log")
    begin
      # download song
      salt = Settings.mp3_salt
      oldUrl = self.url
      hash = Digest::SHA1.hexdigest(salt + oldUrl)
      oldUri = URI(oldUrl)

      sourceMp3 = "tmp/#{hash}.mp3"
      targetMp3 = "public/uploads/#{hash}.mp3"
      newUrl = "#{hostUrl}/uploads/#{hash}.mp3"


      if not File.exist?(targetMp3)
        if not File.exist?(sourceMp3)
          system("curl -L -o #{sourceMp3} #{oldUrl}")
        end
        system("ffmpeg -i #{sourceMp3} -vn -ar 44100 -ac 2 -ab 80000 -f mp3 #{targetMp3}")
      end

      self.isLoaded = true
      self.url = newUrl
      self.save!()
      status = Status.first()
      if status.name.nil?
        PlayerControl.songend() # autostart song
      elsif not status.isLoaded and status.url == oldUrl
        # check if we're waiting for song to load
        status.url = newUrl
        status.isLoaded = true
        status.save!()
        self.destroy()
        PlayerControl.sendPlay()
      end
      system("echo \"Processed #{self.name} to #{newUrl}\" >> delayed.log")
    rescue Exception => e
      system("echo \"Error processing #{e.message}\" >> delayed.log")
    end
  end

  handle_asynchronously :process
end
