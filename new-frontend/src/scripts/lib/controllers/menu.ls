'use strict'

require! chaplin
require! moment
require! cookie

require! MenuView: 'views/menu'

module.exports = class Menu extends chaplin.Controller

  before-action: ->
    <~ $.when super ... .then

    # chaplin.mediator.settings.user = \taystack@gmail.com

    @compose 'menu', ->
      # Dummy model to observe open dropdowns with stickit.
      @model = new chaplin.Model

      @view = new MenuView {
        model: @model
        container: \body
        +auto-render
      }

      # # The collection of strokes on this canvas.
      # @collection = new chaplin.Collection

      # @state = new chaplin.Model {menu: false, user: ''}

      # # Test canvas.
      # @model = new chaplin.Model do
      #   # The initial creator
      #   created: do
      #     user: \taystack@example.com
      #     time: moment!

      #   # Track the changes for potential reversion tools.
      #   changed: [
      #     * user: \taystack@example.com
      #       time: moment!
      #     * user: \bla@example.com
      #       time: moment!
      #     * user: \pholey@example.com
      #       time: moment!
      #   ]

      #   # Some test contributors for display purposes.
      #   contributors: [
      #     * name: \taystack
      #       email: \taystack@example.com
      #       active: true
      #       invited: false
      #     * name: \pholey
      #       email: \pholey@example.com
      #       active: false
      #       invited: true
      #     * name: \bla
      #       email: \bla@example.com
      #       active: true
      #       invited: false
      #   ]
      # @view = new HeaderView {
      #   # user: @user
      #   model: @model
      #   collection: @collection
      #   state: @state
      #   container: \body
      # }
      # @view.render!
