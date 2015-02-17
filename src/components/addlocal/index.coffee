React    = require 'react/addons'
template = require './template.rt.js'

module.exports = React.createFactory React.createClass

  getInitialState: ->
    title: ''
    baseUrl: ''
    matchPattern: ''

  render: template

