'use strict'

require! chaplin
require! cookie

require! Controller: 'lib/controllers/canvas'

require! StrokesView: 'views/strokes'

module.exports = class IndexController extends Controller

  strokes: ->

    canvas_id = cookie.get \canvas_id

    # This is just a bogus collection of strokes.
    # TODO! Remove this when we have actual stroke models
    # generated.
    @collection = new chaplin.Collection

    @stroke-state = new chaplin.Model {menu: false}

    for num in [1 til 10]
      width = 140 + num
      height = 100 + num
      model = new chaplin.Model {
        preview: "http://www.placekitten.com/#width/#height"
        stroke_number: num
        created: moment!
      }
      @collection.push model

    console.log @collection

    @subscribe-event 'stroke:add', (model) ~>
      @collection.push model

    @view = new StrokesView {
      stroke-state: @stroke-state
      collection: @collection
      region: \canvas:strokes
      +auto-render
    }
