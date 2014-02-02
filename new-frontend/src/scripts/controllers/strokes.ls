'use strict'

require! chaplin
require! cookie

require! Controller: 'lib/controllers/menu'

require! StrokesView: 'views/strokes'

module.exports = class IndexController extends Controller

  strokes: ->
    canvas_id = cookie.get \canvas_id

    # This is just a bogus collection of strokes.
    # TODO! Remove this when we have actual stroke models
    # generated.
    @collection = new chaplin.Collection

    @stroke-state = new chaplin.Model {menu: false}

    # Catch the add event from the canvas view.
    @subscribe-event 'stroke:add', (model) ~>
      @collection.unshift model

    # @subscribe-event 'render:strokes', ~>

    console.log 'rendering strokes'

    for num in [1 til 10]
      width = 140 + num
      height = 100 + num
      model = new chaplin.Model {
        preview: "http://www.placekitten.com/#width/#height"
        stroke_number: num
        created: do
          user: chaplin.mediator.settings.user
          time: moment!
      }
      # Add the most recent stroke to the top of the list.
      @collection.unshift model

    @view = new StrokesView {
      user: chaplin.mediator.settings.user
      stroke-state: @stroke-state
      collection: @collection
      region: \region:strokes
      +auto-render
    }

