'use strict'

require! moment

require! ItemView: 'lib/views/view'
require! CollectionView: 'lib/views/collection-view'

require! CollectionTemplate: 'templates/strokes/list'
require! ItemTemplate: 'templates/strokes/item'

# I imagine this area is where we could keep a faux-photoshop
# layers-type view for a user to keep track of each stroke.
class Stroke extends ItemView

  tag-name: \li

  class-name: \stroke-item

  template: ItemTemplate

  bindings:
    '.created':
      observe: \created.time
      on-get: -> moment it .format 'L LT'

    '.author': \created.user

    '.preview':
      attributes: [
        * name: \src
          observe: \preview
      ]

  #   # Maybe an image of the stroke? We can figure this out later.
  #   '.stroke': \path

  events:
    'click': (event) ->
      # TODO: Maybe create a modal with a detail view of this stroke.
      # This type of view implicates that a user can edit/remove this
      # stroke.
      # ---------------------------------------------------------------
      # Remove: Gone!
      # Edit: So many things to list. We can pack features in here.
      #       With a menu detached from the canvas, this could possibly
      #       mean a user could perform strokes on a stroke and add
      #       them to the canvas on the fly. To me, this view will feel
      #       like a smaller detached canvas with all of the features of
      #       its parent. Implementing 'shift + click' could be a
      #       really cool easter egg. What about 'ctrl + click' for
      #       selecting a set of individual strokes? What about giving
      #       the user an option to branch the detail view into a fresh
      #       new Whiteboard? Marinate on that a bit.
      console.log @model


module.exports = class Strokes extends CollectionView

  id: \strokes-list

  item-view: Stroke

  list-selector: \.stroke-items

  template: CollectionTemplate

  state-bindings:
    '.stroke-menu-icon':
      observe: \menu
      attributes: [
        * name: \class
          on-get: (open) -> switch open
          | true => \icon-chevron-up
          | _ => \icon-chevron-down
      ]
      update-view: false

  events:
    'click .stroke-menu': (event) ->
      event.stop-propagation!

      # Toggle the stroke list.
      @$ 'ul.stroke-items' .slide-toggle 500_ms
      @$el.toggle-class \active
      # Toggle the state model.
      @stroke-state.set \menu, not @stroke-state.get \menu

  initialize: (options = {}) ->
    super ...
    @stroke-state = options.stroke-state

  render: ->
    super ...
    console.log \rendering-strokes
    @stickit @stroke-state, @state-bindings

