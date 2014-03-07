'use strict'

require! _: underscore
require! View: 'lib/views/view'
require! CollectionView: 'lib/views/collection-view'
require! Template: 'templates/menu'
require! MenuBrush: 'views/menu/brush'
require! chaplin

# All of the menu items here.
# `repr` is a programatic representation of the action
# `display` is the displayed action
# `view` is the view constructor for this action.

# Each of these building components is an object containing a collection
# containing objects because the structure of the menu is like such:
# menu
# - submenu
#   - item
#   - item
# - submenu
#   - item
# Thus each submenu is a model in the menu collection, and each item is a model
# in the submenu colelction

brushes = do
  label: 'Brushes'
  items: new chaplin.Collection [
    * repr: 'pencil'
      display: 'Pencil'
    * repr: 'wireframe'
      display: 'Wireframe'
    * repr: 'lenny'
      display: '( ͡° ͜ʖ ͡°)'
    * repr: 'copypaste'
      display: 'Copy/Paste'
    * repr: 'sketch'
      display: 'Sketch'
  ]

# Attach the view constructor to the views.
brushes.items.for-each (brush) ->
  brush.set 'view', MenuBrush

tools = do
  label: 'Tools'
  items: new chaplin.Collection [
    * repr: 'tools'
      display: 'Tools'
    * repr: 'csampler'
      display: 'Color Sampler'
    * repr: 'eraser'
      display: 'Eraser'
    * repr: 'smudge'
      display: 'Smudge'
  ]

settings = do
  label: 'Settings'
  items: new chaplin.Collection [
    * repr: 'radius'
      display: 'Raidus'
    * repr: 'colorwheel'
      display: 'Color (r, g, b)'
    * repr: 'alpha'
      display: 'Alpha'
    * repr: 'brightness'
      display: 'Brightness'
  ]

export_menu = do
  label: 'Export'
  items: new chaplin.Collection [
    * repr: 'download'
      display: 'Download'
    * repr: 'share'
      display: 'Share'
  ]

# This doesn't require a complicated collection or model since its not synced
# with the server.
menu-items = new chaplin.Collection [brushes, tools, settings, export_menu] do
  model: chaplin.Model


class SubMenu extends CollectionView

  animation-duration: 0
  list-selector: 'ul'
  tag-name: 'li'
  attributes:
    'class': 'has-sub'

  template: ->
    '<span /><ul></ul>'

  bindings:
    'span': 'label'

  init-item-view: (model) ->
    if model.get 'view'
      new that {model}
    else
      new MenuBrush {model}

module.exports = class Menu extends CollectionView

  animation-duration: 0
  item-view: SubMenu
  item-selector: 'ul'
  template: Template
  no-wrap: true
  attributes:
    'class': 'menu'

  (options = {}) ->
    options.collection = menu-items
    super options

  init-item-view: (model) ->
    new @item-view do
      model: model
      collection: model.get 'items'
