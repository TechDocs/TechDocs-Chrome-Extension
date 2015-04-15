riot      = require 'riot'
datastore = require './lib/datastore'
convert   = require './lib/convert'

require '../components/popup.html'
require '../components/translation-link.html'

CONT_URL = 'https://github.com/TechDocs/TechDocs'

find = (collection, predicate) ->
  for record in collection
    return record if predicate record
  null

addPath = (sitefiles, current, path) ->
  curSf = find sitefiles, (obj) -> obj.id == current
  # calculate original path
  path = if curSf.origin? then convert.reverse path, curSf.rules else path
  # calculate translated path for each
  sitefiles.map (sf) ->
    sf.path = if sf.origin? then convert path, sf.rules else path
    sf

chrome.tabs.getSelected window.id, (tab) ->
  popup = null

  if curSf = datastore.getOneMatchPrefix tab.url, ['url']
    curPath = tab.url.replace curSf.url, ''
    orgId = if curSf.origin then curSf.origin else curSf.id

    # At first, get data in local
    translations = datastore.getListEq orgId, ['origin', 'id'], (results) ->
      # If there're no cache, get data from remote
      popup.update translations: addPath results, curSf.id, curPath
    # Calculate Paths
    translations = addPath translations, curSf.id, curPath

  opts =
    title: orgId || 'search'
    url: tab.url
    tabId: tab.id
    contributingUrl: CONT_URL
    current: curSf?.id || ''
    translations: translations || []
    index: datastore.getIndex()
    reload: datastore.reload

  popup = (riot.mount 'popup', opts)[0]
