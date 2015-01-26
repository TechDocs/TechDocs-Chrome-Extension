ROOT_URL       = 'http://techdocs.github.io/TechDocs'
STORAGE_PREFIX = 'techdocs'

cache = {}

getIndex = ->
  unless cache.index?
    id = "#{STORAGE_PREFIX}-index"
    cache.index = JSON.parse localStorage.getItem id
  cache.index

# Get the indexed deata from techdocs.io
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

# Check the URL exists in the list
urlExists = (url) ->
  unless cache.urllist?
    id = "#{STORAGE_PREFIX}-urllist"
    cache.urllist = JSON.parse localStorage.getItem id

  for prefix in cache.urllist
    if 0 == url.indexOf prefix
      return true
  false

getSiteByUrl = (url) ->
  for id, site of getIndex()
    if 0 == url.indexOf site.url
      site.id = id
      return site
  null

getRelatedSites = (siteId) ->
  index = getIndex()
  origin = index[siteId]?.origin or siteId
  related = []
  for id, site of index when (origin == site.origin or origin == id) and id isnt siteId
    site.id = id
    related.push site
  related

module.exports =
  updateIndex: updateIndex
  urlExists: urlExists
  getSiteByUrl: getSiteByUrl
  getRelatedSites: getRelatedSites

