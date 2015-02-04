React    = require 'react/addons'
template = require './template.rt.js'

module.exports = React.createFactory React.createClass

  getInitialState: ->
    searchString: ''

  componentDidMount: ->

  handleChange: (e) ->
    searchString = e.target.value.trim().toLowerCase()
    @setState
      searchString: searchString
    return unless searchString.length
    @filtered = @props.index
      .filter (sf) -> sf.id.replace(/\-\w\w$/, '').match searchString
      .slice 0, 10

  goto: (url, e) ->
    e.preventDefault()
    chrome.tabs.update @props.tabId, url: url
    window.close()

  render: template