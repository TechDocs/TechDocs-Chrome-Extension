clone = require 'clone'

ROOT_URL       = 'http://techdocs.github.io/TechDocs'
STORAGE_PREFIX = 'techdocs'

cache = {}

getIndex = ->
  unless cache.index?
    storageId = "#{STORAGE_PREFIX}-index"
    cache.index = JSON.parse localStorage.getItem storageId
  cache.index

getSitefiles = (ids) -> Promise.all ids.map getSitefile
getSitefile = (id) ->
  new Promise (resolve, reject) ->
    if sitefile = getSitefileFromCache id
      resolve sitefile
    else
      updateSitefile id, (sf) -> resolve sf

getSitefileFromCache = (id) ->
  if cache.sitefiles? and cache.sitefiles[id]?
    return cache.sitefiles[id]

  storageId = "#{STORAGE_PREFIX}-sitefile-#{id}"
  cache.sitefiles = {} unless cache.sitefiles?
  if str = localStorage.getItem storageId
    cache.sitefiles[id] = JSON.parse str
    return cache.sitefiles[id]

  return false

# Get the indexed data from techdocs.io
updateIndex = (cb) ->
  xhr = new XMLHttpRequest()
  xhr.open 'GET', "#{ROOT_URL}/index.json", true
  xhr.onreadystatechange = ->
    return unless xhr.readyState == 4

    localStorage.setItem "#{STORAGE_PREFIX}-index", xhr.responseText
    index = JSON.parse xhr.responseText
    urllist =
      site.url for id, site of index
    localStorage.setItem "#{STORAGE_PREFIX}-urllist", JSON.stringify urllist

    cache.index = index
    cache.urllist = urllist

    cb index if cb
  xhr.send()

# Get the sitefile from techdocs.io
updateSitefile = (id, cb) ->
  xhr = new XMLHttpRequest()
  xhr.open 'GET', "#{ROOT_URL}/sitefiles/#{id}.json", true
  xhr.onreadystatechange = ->
    return unless xhr.readyState == 4

    localStorage.setItem "#{STORAGE_PREFIX}-sitefile-#{id}", xhr.responseText
    sitefile = JSON.parse xhr.responseText

    cache.sitefiles = {} unless cache.sitefiles?
    cache.sitefiles[id] = sitefile

    cb sitefile if cb
  xhr.send()

# Check the URL exists in the list
urlExists = (url) ->
  unless cache.urllist?
    storageId = "#{STORAGE_PREFIX}-urllist"
    cache.urllist = JSON.parse localStorage.getItem storageId

  for prefix in cache.urllist
    if 0 == url.indexOf prefix
      return true
  false

getSiteByUrl = (url) ->
  for id, site of getIndex()
    if 0 == url.indexOf site.url
      site.id = id
      return clone site
  null

getRelatedSites = (siteId, cb) ->
  index = getIndex()
  origin = index[siteId]?.origin or siteId
  relatedIds =
    id for id, site of index when origin == site.origin or origin == id

  getSitefiles relatedIds
  .then (sitefiles) ->
    for i in [0...sitefiles.length]
      sitefiles[i].isSelf = (siteId == sitefiles[i].id)

    cb sitefiles.sort (a, b) ->
      return 1 if a.language > b.language
      return -1 if a.language < b.language
      0

module.exports =
  updateIndex: updateIndex
  urlExists: urlExists
  getSiteByUrl: getSiteByUrl
  getRelatedSites: getRelatedSites

