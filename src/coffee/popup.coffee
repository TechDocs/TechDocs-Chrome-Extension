domready  = require 'domready'
datastore = require './lib/datastore'
convert   = require './lib/convert'
template  = require '../templates/popup.hbs'

emulateLinkBehavior = (el, tabId) ->
  el.addEventListener 'click', (e) =>
    e.preventDefault()
    chrome.tabs.update tabId, url: el.getAttribute 'href'
    window.close()
  , false

show = (site, related, tabId) ->
  dom = document.body
  dom.innerHTML = template
    isRegistered: site isnt null
    isTranslated: related.length > 0
    siteId: site?.id
    related: related
    group: site?.origin or site?.id or null

  emulateLinkBehavior el, tabId for el in dom.getElementsByTagName 'a'

getSiteById = (id, sitefiles) ->
  for sitefile in sitefiles
    return sitefile if sitefile.id == id
  return null

domready ->
  chrome.tabs.getSelected window.id, (tab) ->
    url = tab.url
    site = datastore.getSiteByUrl url
    return show null, [] unless site

    datastore.getRelatedSites site.id, (results) ->
      site = getSiteById site.id, results
      path = url.replace site.url, ''
      path = convert.reverse path, site.rules if site.origin?
      related = results.map (result) ->
        tpath = path
        tpath = convert path, result.rules if result.origin?
        result.url += '/' unless /\/$/.test result.url
        result.url += tpath
        result
      show site, related, tab.id
