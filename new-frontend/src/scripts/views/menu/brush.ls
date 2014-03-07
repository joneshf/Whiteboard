'use strict'

require! View: 'lib/views/view'

module.exports = class MenuBrush extends View

  tag-name: 'li'

  auto-attach: false

  bindings:
    'span': 'display'

  template: ->
    "<span />"
