Streammeup.ApplicationController = Ember.Controller.extend
    isLoading: false
    isPlaying: false
    currentSong: null

    newSongName: null
    newSongUrl: null

    isSearching: false
    searchQuery: null
    searchResults: null

    # clean up poll

    pollServer: ->
        $.getJSON(  
            "/home/status",  
            {},  
            (json) =>
                result = json
                if result and result.success
                    @set 'isLoading', !result.isLoaded
                    @set 'isPlaying', result.isPlaying
                    @set 'currentSong', result.song
                    @set 'songs', result.songs
        )  

    init: ->
        setInterval(=>
            @pollServer()
        , 1000)

    play: ->
        $.getJSON(  
            "/home/play",  
            {},  
            (json) =>
        )  

    pause: ->
        $.getJSON(  
            "/home/pause",  
            {},  
            (json) =>
        )  

    stop: ->
        $.getJSON(  
            "/home/stop",  
            {},  
            (json) =>
        )  

    skip: ->
        $.getJSON(
            "/home/songend",
            {},
            (json) =>
        )

    addSearchResult: (song) ->
        $.getJSON(
            "/home/addresult",
            {name: song.title, artist: song.artist, url: song.url},
            (json) =>
        )
        @set "searchResults", null
        return false

    addSong: ->
        $.getJSON(
            "/home/addsong",
            {name: @get('newSongName'), url: @get('newSongUrl')},
            (json) =>
        )
        @set "newSongName", ""
        @set "newSongUrl", ""

    search: ->
        @set 'isSearching', true
        $.getJSON(
            "/home/search",
            {query: @get('searchQuery') },
            (json) => 
                @set 'isSearching', false
                result = json
                if result and result.success
                    @set "searchResults", result.songs
        )
        @set "searchQuery", ""

