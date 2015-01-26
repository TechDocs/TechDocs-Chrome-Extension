domready  = require 'domready'
datastore = require './lib/datastore'
template  = require '../templates/popup.hbs'

domready ->
  chrome.tabs.getSelected window.id, (tab) ->
    site = datastore.getSiteByUrl tab.url

    dom = document.body
    dom.innerHTML = template
      title:    site.title
      url:      site.url
      language: site.language
      related:  if site then datastore.getRelatedSites site.id else []

    for el in dom.getElementsByTagName 'a'
      el.addEventListener 'click', (e) =>
        e.preventDefault()
        chrome.tabs.update tab.id, url: el.getAttribute 'href'
        window.close()
      , false
