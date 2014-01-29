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