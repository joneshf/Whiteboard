'use strict'

require! View: 'lib/views/view'
require! Template: 'templates/easel'

module.exports = class EaselView extends View

  container: \body

  template: Template

  regions:
    'main-menu': '.menu-container'
    'canvas': '.canvas-container'
