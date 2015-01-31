clone = require 'clone'

ROOT_URL       = 'http://techdocs.github.io/TechDocs'
STORAGE_PREFIX = 'techdocs'
STORAGE_TABLE  = 'sitefiles'

cache = {}

sorter = (col, desc = false) ->
  sign = if desc then -1 else 1
  (a, b) ->
    return sign * 1    if a[col] > b[col]
    return sign * (-1) if a[col] < b[col]
    0

reload = ->
  localStorage.clear()
  cache = {}
  syncIndex ->
    # Reload Self
    window.location.href = 'popup.html'

getIndex = ->
  unless cache.index?
    storageId = "#{STORAGE_PREFIX}-index"
    cache.index = JSON.parse localStorage.getItem storageId
  cache.index

getOneFromCache = (id) ->
  if cache.rows? and cache.rows[id]?
    return cache.rows[id]

  storageId = "#{STORAGE_PREFIX}-#{STORAGE_TABLE}-#{id}"
  cache.rows = {} unless cache.rows?
  if str = localStorage.getItem storageId
    cache.rows[id] = JSON.parse str
    return cache.rows[id]

  return false

# Get the sitefile from techdocs.io
syncRecord = (id, cb) ->
  xhr = new XMLHttpRequest()
  xhr.open 'GET', "#{ROOT_URL}/#{STORAGE_TABLE}/#{id}.json", true
  xhr.onreadystatechange = ->
    return unless xhr.readyState == 4

    localStorage.setItem "#{STORAGE_PREFIX}-#{STORAGE_TABLE}-#{id}", xhr.responseText
    row = JSON.parse xhr.responseText

    cache.rows = {} unless cache.rows?
    cache.rows[id] = row

    cb row if cb
  xhr.send()

# Get the indexed data from techdocs.io
syncIndex = (cb) ->
  xhr = new XMLHttpRequest()
  xhr.open 'GET', "#{ROOT_URL}/index.json", true
  xhr.onreadystatechange = ->
    return unless xhr.readyState == 4

    localStorage.setItem "#{STORAGE_PREFIX}-index", xhr.responseText
    index = JSON.parse xhr.responseText
    urllist =
      row.url for row in index
    localStorage.setItem "#{STORAGE_PREFIX}-urllist", JSON.stringify urllist

    cache.index = index
    cache.urllist = urllist

    cb index if cb
  xhr.send()

# Check the URL exists in the list
urlExists = (url) ->
  unless cache.urllist?
    storageId = "#{STORAGE_PREFIX}-urllist"
    cache.urllist = JSON.parse localStorage.getItem storageId

  return true for prefix in cache.urllist when 0 == url.indexOf prefix
  false

# Get a record which is the prefix of `val`
getOneMatchPrefix = (val, columns, cb) ->
  for row in getIndex().reverse()
    for col in columns when 0 == val.indexOf row[col]
      if r = getOneFromCache row.id
        row = r
      else if cb
        syncRecord row.id, cb
      return clone row
  null

# Get the list of records which match the condition
# 1. create list from index
# 2. try to get the data from cache or local storage
# 3. return the list sync
# 4. request the data to the remote
# 5. return the list async via callback
getListEq = (val, columns, cb) ->
  arr = []
  notFound = false
  for row in getIndex()
    for col in columns when val == row[col]
      if r = getOneFromCache row.id
        arr.push clone r
      else
        arr.push clone row
        notFound = true

  if cb and notFound
    promises =
      for row in arr
        new Promise (resolve, reject) ->
          syncRecord row.id, resolve
    Promise.all promises
    .then (rows) ->
      cb rows.sort sorter 'id'

  return arr

module.exports =
  syncIndex: syncIndex
  urlExists: urlExists
  getOneMatchPrefix: getOneMatchPrefix
  getListEq: getListEq
  reload: reload
  getIndex: getIndex
