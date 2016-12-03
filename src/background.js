import { urlExists, syncIndex } from './lib/datastore'

// TODO: cache
syncIndex()

function updateButtonUI (tab) {
  chrome.browserAction.setTitle({
    title: 'TechDocs',
    tabId: tab.id
  })
  function change (icon) {
    chrome.browserAction.setIcon({
      path: {'38': icon},
      tabId: tab.id
    })
  }

  if (urlExists(tab.url)) change('btn-red.png')
  else change('btn-gray.png')
}

/** Detect when url changes */
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete') updateButtonUI(tab)
})
