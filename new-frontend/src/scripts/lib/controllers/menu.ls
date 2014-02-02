'use strict'

require! chaplin
require! moment
require! cookie

require! MenuView: 'views/menu'
require! CanvasView: 'views/canvas'

module.exports = class Menu extends chaplin.Controller

  before-action: ->
    <~ $.when super ... .then

    # chaplin.mediator.settings.user = \taystack@gmail.com

    @compose 'menu', ->
      # Dummy model to observe open dropdowns with stickit.
      @model = new chaplin.Model

      @state = new chaplin.Model {menu: false, user: ''}

      @view = new MenuView {
        state: @state
        model: @model
        container: \body
        +auto-render
      }

      # Set the width and height of the canvas.
      # TODO: Set these with the initial menu.
      chaplin.mediator.settings.canvas_width = \900px
      chaplin.mediator.settings.canvas_height = \500px

      # The collection of strokes on this canvas.
      @collection = new chaplin.Collection

      # Test canvas.
      @canvas = new chaplin.Model do
        # The initial creator
        created: do
          user: \taystack@example.com
          time: moment!

        # Track the changes for potential reversion tools.
        changed: [
          * user: \taystack@example.com
            time: moment!
            stroke: 1
          * user: \bla@example.com
            time: moment!
            stroke: 2
          * user: \pholey@example.com
            time: moment!
            stroke: 3
        ]

        # Some test contributors for display purposes.
        contributors: [
          * name: \taystack
            email: \taystack@example.com
            active: true
            invited: false
          * name: \pholey
            email: \pholey@example.com
            active: false
            invited: true
          * name: \bla
            email: \bla@example.com
            active: true
            invited: false
        ]

      @canvas-state = new chaplin.Model {
        is-drawing: false
      }

      @canvas-view = new CanvasView {
        state: @canvas-state
        model: @model
        collection: @collection
        region: \region:canvas
      }
      @canvas-view.render!
