'use strict'

require! chaplin
require! $: jquery

require! EaselView: 'views/easel'
require! MenuView: 'views/menu'

module.exports = class EaselController extends chaplin.Controller

  before-action:->
    @reuse 'easel', ->
      @view = new EaselView do
        container: \body
        auto-render: true

      @menu = new MenuView do
        region: 'main-menu'
        auto-render: true

  default: ->
