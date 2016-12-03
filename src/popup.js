import riot from 'riot'
import { getOneMatchPrefix, getListEq, getIndex, reload } from './lib/datastore'
import { convert, reverse } from './lib/convert'

import './components/popup.tag'
import './components/translation-link.tag'

const contributingUrl = 'https://github.com/TechDocs/TechDocs'
const homeUrl = 'http://techdocs.io/'

function addPath (sitefiles, current, path) {
  const curSf = sitefiles.find(obj => obj.id === current)
  // calculate original path
  path = curSf.origin ? reverse(path, curSf.rules) : path
  // calculate translated path for each
  return sitefiles.map(sf => Object.assign(sf, {
    path: sf.origin ? convert(path, sf.rules) : path
  }))
}

chrome.tabs.getSelected(window.id, tab => {
  let popup = null
  let orgId = ''
  let translations = []
  const curSf = getOneMatchPrefix(tab.url, ['url'])
  if (curSf) {
    const curPath = tab.url.replace(curSf.url, '')
    orgId = curSf.origin ? curSf.origin : curSf.id
    // At first, get data in local
    translations = getListEq(orgId, ['origin', 'id'], results => {
      // If there're no cache, get data from remote
      popup.update({
        translations: addPath(results, curSf.id, curPath)
      })
    })
    // Calculate Paths
    translations = addPath(translations, curSf.id, curPath)
  }
  const opts = {
    title: orgId || 'search',
    url: tab.url,
    tabId: tab.id,
    contributingUrl,
    homeUrl,
    current: curSf && curSf.id || '',
    translations,
    index: getIndex(),
    reload
  }
  popup = riot.mount('popup', opts)[0]
})
