React    = require 'react/addons'
template = require './template.rt.js'

module.exports = React.createFactory React.createClass

  getInitialState: -> {}

  componentDidMount: ->

  goto: (url, e) ->
    e.preventDefault()
    chrome.tabs.update @props.tabId, url: url
    window.close()

  render: template