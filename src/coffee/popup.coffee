domready  = require 'domready'
React     = require 'react/addons'
Popup     = require './lib/popup'
datastore = require './lib/datastore'
convert   = require './lib/convert'

CONT_URL = 'https://github.com/TechDocs/TechDocs'

getSiteById = (id, sitefiles) ->
  for sitefile in sitefiles
    return sitefile if sitefile.id == id
  return null

domready ->
  chrome.tabs.getSelected window.id, (tab) ->
    props =
      title: '* * *'
      url: tab.url
      tabId: tab.id
      contributingUrl: CONT_URL
      translations: []

    unless site = datastore.getSiteByUrl props.url
      return React.render Popup(props), document.body

    datastore.getRelatedSites site.id, (results) ->
      site = getSiteById site.id, results
      path = props.url.replace site.url, ''
      path = convert.reverse path, site.rules if site.origin?

      props.title = if site.origin? then site.origin else site.id
      props.translations = results.map (result) ->
        tpath = path
        tpath = convert path, result.rules if result.origin?
        result.url += '/' unless /\/$/.test result.url
        result.url += tpath
        result
      React.render Popup(props), document.body
