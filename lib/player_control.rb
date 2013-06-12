class PlayerControl
  def self.sendCommand(command)
    appUrl = Settings.app_url
    appUrl += "?value=" + command
    system("curl #{appUrl}")
  end

  def self.sendPlay
    status = Status.first()
    return if status.isPlaying or status.name.nil?
    sendCommand(Rack::Utils.escape("play|#{status.url}"))
    status.isPlaying = true
    status.save!()
  end

  def self.sendPause
    status = Status.first()
    return if not status.isPlaying
    sendCommand("pause")
    status.isPlaying = false
    status.save!()
  end

  def self.sendStop
    status = Status.first()
    sendCommand("stop")
    status.isPlaying = false
    status.save!()
  end

  def self.songend
    song = Song.first()
    status = Status.first()
    sendStop()
    if song.nil?
      status.name = nil
      status.save!()
    else
      status.name = song.name
      status.artist = song.artist
      status.url = song.url
      status.isLoaded = song.isLoaded
      status.save!()
      if song.isLoaded
        song.destroy()
        sendPlay()
      end
    end
  end
end
