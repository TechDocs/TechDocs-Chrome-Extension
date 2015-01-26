domready  = require 'domready'
datastore = require './lib/datastore'
template  = require '../templates/popup.hbs'

domready ->
  chrome.tabs.getSelected window.id, (tab) ->
    site = datastore.getSiteByUrl tab.url
    related = if site then datastore.getRelatedSites site.id else []

    dom = document.body
    dom.innerHTML = template
      isRegistered: site isnt null
      isTranslated: related.length > 0
      related: related

    for el in dom.getElementsByTagName 'a'
      el.addEventListener 'click', (e) =>
        e.preventDefault()
        chrome.tabs.update tab.id, url: el.getAttribute 'href'
        window.close()
      , false
