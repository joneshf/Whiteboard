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
    'mousedown': (event) ->

      console.log event

      changes = @model.get \changed

      # Govern the button that fired this event.
      switch event.button
      # Only catch the left mouse click
      | 0 =>
        # Fade out the title screen.
        # @$ '.title' .fade-out 250_ms

        # More custom logic.
        console.log 'Instantiate a brush stroke?'

        # Set the timestamp on our model.
        @model.set {
          changed:
            user: chaplin.mediator.settings.user
            time: moment!
        }

        console.log @model

      # We can add different functionality to other buttons.
      | _ =>
        console.log 'Unreserved mouse action.'

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

    @publish-event 'render:strokes'

  update-canvas: ->
    changes = @model.get \changed
    change = do
      user: chaplin.mediator.settings.user
      time: moment!
    changes = _.extend changes, change
    @model.set \changed, changes
