'use strict'

require! chaplin

# Moment for timestamps.
require! moment

# Require our base view.
require! View: 'lib/views/view'

require! Template: 'templates/menu/menu'

module.exports = class Menu extends View

  id: \menu

  template: Template

  regions:
    'canvas-region': \.canvas-region
    'stroke-region': \.stroke-region

  events:
    'submit': (event) ->
      event.prevent-default!

      @state.set \user, (@$ '.user-email' .val!)

      # Let the strokes view know we are starting this thing.
      @publish-event 'render:strokes', @state.get \user

      # Hide the login
      @$ '.title' .hide!
      # Show the menu
      @$ '.menu-selector' .fade-in 250_ms

    'click .menu-selector > .toggle-switch': (event) ->
      # !TODO: This here still propagates to the mousedown event.
      event.stop-propagation!

      # Toggle the menu.
      @$ 'ul.menu-items' .slide-toggle 250_ms
      @$ '.toggle-switch' .toggle-class \active
      # Toggle the state of the menu.
      @state.set \menu, not @state.get \menu

    # Add a fake model to the canvas.
    'click .menu-selector .add-fake': (event) ->
      num = @collection.length
      width = 140 + num
      height = 100 + num
      model = new chaplin.Model do
        preview: "http://www.placekitten.com/#width/#height"
        stroke_number: num
        created: do
          user: chaplin.mediator.settings.user
          time: moment!

      @publish-event 'stroke:add', model

  render: ->
    super ...

    @$ '.title' .hide!
    @$ '.menu-selector' .fade-in 250_ms


  initialize: (options = {}) ->
    super ...
    @state = options.state