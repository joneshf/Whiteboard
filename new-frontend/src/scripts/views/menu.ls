'use strict'

require! _: underscore
require! View: 'lib/views/view'
require! CollectionView: 'lib/views/collection-view'
require! Template: 'templates/menu'
require! chaplin

brushes = [
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

# menu-collection = new chaplin.Collection do

module.exports = class Menu extends View

  tagname: 'ul'

  attributes:
    'class': 'menu'

  template: Template

  get-template-function: ->
    return @template
