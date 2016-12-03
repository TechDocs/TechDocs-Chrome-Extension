const ROOT_URL = 'http://techdocs.github.io/TechDocs'
const STORAGE_PREFIX = 'techdocs'
const STORAGE_TABLE = 'sitefiles'

let cache = {}

function getOneFromCache (id) {
  if (cache.rows && cache.rows[id]) return cache.rows[id]
  cache.rows = cache.rows || {}
  const storageId = `${STORAGE_PREFIX}-${STORAGE_TABLE}-${id}`
  const str = localStorage.getItem(storageId)
  if (!str) return false
  cache.rows[id] = JSON.parse(str)
  return cache.rows[id]
}

/** Get the sitefile from techdocs.io */
function syncRecord (id, cb) {
  const xhr = new XMLHttpRequest()
  xhr.open('GET', `${ROOT_URL}/${STORAGE_TABLE}/${id}.json`, true)
  xhr.onreadystatechange = () => {
    if (xhr.readyState !== 4) return
    localStorage.setItem(`${STORAGE_PREFIX}-${STORAGE_TABLE}-${id}`, xhr.responseText)
    const row = JSON.parse(xhr.responseText)
    cache.rows = cache.rows || {}
    cache.rows[id] = row
    if (cb) cb(row)
  }
  xhr.send()
}

export function reload () {
  localStorage.clear()
  cache = {}
  syncIndex(() => {
    // Reload Self
    window.location.href = 'popup.html'
  })
}

export function getIndex () {
  if (!cache.index) cache.index = JSON.parse(localStorage.getItem(`${STORAGE_PREFIX}-index`))
  return cache.index
}

/** Get the indexed data from techdocs.io */
export function syncIndex (cb) {
  const xhr = new XMLHttpRequest()
  xhr.open('GET', `${ROOT_URL}/index.json`, true)
  xhr.onreadystatechange = () => {
    if (xhr.readyState !== 4) return
    localStorage.setItem(`${STORAGE_PREFIX}-index`, xhr.responseText)
    const index = JSON.parse(xhr.responseText)
    const urllist = index.map(row => row.url)
    localStorage.setItem(`${STORAGE_PREFIX}-urllist`, JSON.stringify(urllist))
    cache.index = index
    cache.urllist = urllist
    if (cb) cb(index)
  }
  xhr.send()
}

/** Check the URL exists in the list */
export function urlExists (url) {
  const storageId = `${STORAGE_PREFIX}-urllist`
  cache.urllist = cache.urllist || JSON.parse(localStorage.getItem(storageId))
  return cache.urllist.some(prefix => url.indexOf(prefix) === 0)
}

/** Get a record which is the prefix of `val` */
export function getOneMatchPrefix (val, columns, cb) {
  const record = getIndex()
    .reverse()
    .find(row => columns.some(col => val.indexOf(row[col]) === 0))

  if (!record) return null
  const r = getOneFromCache(record.id)
  if (r) return Object.assign({}, r)
  if (cb) syncRecord(record.id, cb)
  return Object.assign({}, record)
}

/**
 * Get the list of records which match the condition
 * 1. create list from index
 * 2. try to get the data from cache or local storage
 * 3. return the list sync
 * 4. request the data to the remote
 * 5. return the list async via callback
 */
export function getListEq (val, columns, cb) {
  let notFound = false
  const arr = getIndex()
    .filter(row => columns.some(col => val === row[col]))
    .map(row => {
      const r = getOneFromCache(row.id)
      if (r) return Object.assign({}, r)
      notFound = true
      return Object.assign({}, row)
    })

  if (cb && notFound) {
    Promise.all(arr.map(row => new Promise(resolve => {
      syncRecord(row.id, resolve)
    })))
      .then(rows => {
        cb(rows.sort((a, b) => a.id > b.id ? 1 : a.id < b.id ? -1 : 0))
      })
  }
  return arr
}
