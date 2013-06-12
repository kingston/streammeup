require 'open-uri'

class HomeController < ApplicationController
  skip_before_filter :require_login, :only => [ :songend ]

  def index
  end

  def sendCommand(command)
    appUrl = Settings.app_url
    appUrl += "?value=" + command
    open(appUrl) {|f|
    }
  end

  def status
    status = Status.first()
    if status.nil?
      status = Status.new({
        :name => nil,
        :artist => nil,
        :url => nil,
        :isPlaying => false,
        :isLoaded => true
      })
      status.save!()
    end
    if status.name.nil?
      song = nil
    else
      song = {
        :name => status.name,
        :artist => status.artist,
      }
    end
    songs = Song.all()
    songsJson = []
    songs.each do |curSong|
      songsJson.push({
        :name => curSong.name,
      })
    end
    render :json => {
      :success => true,
      :song => song,
      :isPlaying => status.isPlaying,
      :isLoaded => status.isLoaded,
      :songs => songsJson
    }
  end

  def sendPlay
    status = Status.first()
    return if status.isPlaying or status.name.nil?
    sendCommand(Rack::Utils.escape("play|#{status.url}"))
    status.isPlaying = true
    status.save!()
  end

  def sendPause
    status = Status.first()
    return if not status.isPlaying
    sendCommand("pause")
    status.isPlaying = false
    status.save!()
  end

  def sendStop
    status = Status.first()
    sendCommand("stop")
    status.isPlaying = false
    status.save!()
  end

  def play
    sendPlay()
    render :json => { :success => true }
  end

  def pause
    sendPause()
    render :json => { :success => true }
  end

  def stop
    sendStop()
    render :json => { :success => true }
  end

  def search
    if params[:query].nil?
      render :json => { :success => false, :message => "No query provided" } 
      return
    elsif params[:query].length > 50
      render :json => { :success => false, :message => "Query too long" } 
      return
    end
    #searchUrl = "http://ex.fm/api/v3/song/search/" + Rack::Utils.escape(params[:query]) + "?results=5"
    searchUrl = "http://sdi.ktam.org/test.json"

    results = ActiveSupport::JSON.decode(open(searchUrl).read)
    if results['status_code'] != 200
      render :json => { :success => false, :message => "Invalid response from server #{results['status_text']}" } 
      return
    end

    songs = results['songs']
    songs_output = []
    songs.each { |song|
      songs_output.push({
        :title => song['title'],
        :url => song['url'],
        :artist => song['artist'],
      })
    }
    render :json => {
      :success => true,
      :songs => songs_output,
    }
  end

  def addresult
    if params[:name].nil? or params[:artist].nil? or params[:url].nil?
      render :json => { :success => false }
    end

    song = Song.create({
      :name => params[:name],
      :url => params[:url]
    })
    song.save!()

    status = Status.first()
    if status.name.nil?
      songend() # autostart song
    else
      render :json => { :success => true }
    end
  end

  def songend
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
      status.save!()
      song.destroy()
      sendPlay()
    end
    render :json => { :success => true }
  end

  def addsong
    if params[:name].nil? or params[:url].nil?
      render :json => { :success => false }
      return
    end

    song = Song.create({
      :name => params[:name],
      :url => params[:url]
    })
    song.save!()

    status = Status.first()
    if status.name.nil?
      songend() # autostart song
    else
      render :json => { :success => true }
    end
  end
end
