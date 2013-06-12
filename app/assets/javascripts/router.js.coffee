Streammeup.PlaylistController = Ember.Route.extend
  setupController: (controller) ->

Streammeup.Router.map (match)->
  @route("playlist", { path: "/"})

