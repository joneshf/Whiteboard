'use strict'

require! chaplin

# Moment for timestamps.
require! moment

# Require our base views.
require! ItemView: 'lib/views/view'
require! CollectionView: 'lib/views/collection-view'

require! ItemTemplate: 'templates/canvas/stroke'
require! CollectionTemplate: 'templates/canvas/canvas'

module.exports = class Stroke extends ItemView

  template: ItemTemplate

  tag-name: \li

  class-name: \canvas-stroke

module.exports = class Canvas extends CollectionView

  id: \canvas

  template: CollectionTemplate

  list-selector: \.items

  item-view: Stroke

  regions:
    'canvas:strokes': \.canvas-strokes

  state-bindings:
    '.user-email': \user

    '.user-form > button':
      observe: \user
      attributes: [
        * name: \disabled
          on-get: (user) -> switch user
          | '' => true
          | _ => false
      ]
      update-view: false

    '.menu-icon':
      observe: \menu
      attributes: [
        * name: \class
          on-get: (open) -> switch open
          | true => \icon-chevron-up
          | _ => \icon-chevron-down
      ]
      update-view: false

  # Some custom key bindings to reference.
  ctrl-z: (event)-> event.which is 90_z and event.ctrl-key

  events:
    'submit': (event) ->
      event.prevent-default!

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

    'mousedown': (event) ->
      # Govern the button that fired this event.
      switch event.button
      # Only catch the left mouse click
      | 0 =>
        # Fade out the title screen.
        # @$ '.title' .fade-out 250_ms

        # More custom logic.
        console.log 'Instantiate a brush stroke?'

        # Set the timestamp on our model.
        @model.set \changed, moment!

      # We can add different functionality to other buttons.
      | _ =>
        console.log 'Unreserved mouse action.'

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

      @collection.unshift model

    'mouseup': (event) ->
      # make sure we don't have the menu open.
      unless @state.get \menu
        switch event.button
        # Only catch the left mouse click
        | 0 =>
          # I guess this is where we would end  the life of a
          @update-canvas!

  initialize: (options = {}) ->
    super ...

    @state = options.state

    @state.on 'change:user', (model) ~>
      chaplin.mediator.settings.user = model.get \user

    # Check whe window on all keyup events.
    $ window .on 'keyup', (event) ~>
      if ctrl = event.ctrl-key
        switch event.which
        | 90_z =>
          # Undo function call here.
          console.log 'undo function'

    # Listen to the add event on out canvas.
    @collection.on 'add', (model) ~>
      # Publish the new stroke to the strokes controller.
      @publish-event 'stroke:add', model

  render: ->
    super ...

    @stickit @state, @state-bindings

  update-canvas: ->
    changes = @model.get \changed
    change = do
      user: chaplin.mediator.settings.user
      time: moment!
    changes = _.extend changes, change
    @model.set \changed, changes
