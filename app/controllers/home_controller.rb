require 'player_control'
require 'open-uri'

class HomeController < ApplicationController
  skip_before_filter :require_login, :only => [ :songend ]

  def init
  end

  def index
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
        :artist => curSong.artist,
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

  def play
    PlayerControl.sendPlay()
    render :json => { :success => true }
  end

  def pause
    PlayerControl.sendPause()
    render :json => { :success => true }
  end

  def stop
    PlayerControl.sendStop()
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
    searchUrl = "http://ex.fm/api/v3/song/search/" + Rack::Utils.escape(params[:query]) + "?results=5"
    #searchUrl = "http://sdi.ktam.org/test.json"

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
      :artist => params[:artist],
      :url => params[:url],
      :isLoaded => false
    })
    song.save!()

    song.process("#{request.protocol}#{request.host_with_port}")

    status = Status.first()
    if status.name.nil?
      PlayerControl.songend() # autostart song
    end

    render :json => { :success => true }
  end

  def songend
    PlayerControl.songend
    render :json => { :success => true }
  end

  def addsong
    if params[:name].nil? or params[:url].nil?
      render :json => { :success => false }
      return
    end

    song = Song.create({
      :name => params[:name],
      :url => params[:url],
      :isLoaded => true
    })
    song.save!()

    status = Status.first()
    if status.name.nil?
      PlayerControl.songend() # autostart song
    end
    render :json => { :success => true }
  end
end
