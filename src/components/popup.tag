<popup>
  <header>
    <input class="search" type="search" placeholder="{ opts.title }"
      value="{ searchString }" onChange="{ handleChange }" >
  </header>
  <p if={ !searchString && opts.translations.length == 0} >
    Is this a technical document?<br>
    <a href="#" onclick={ click } >
      Let's make PR to add it to TechDocs!</a>
  </p>
  <p if={ !searchString && opts.translations.length == 1} >
    This document is already registered. Do you know the translation for it?<br>
    <a href="#" onclick={ click } >
      Let's make PR to add it to TechDocs!</a>
  </p>
  <ul if={ !searchString && opts.translations.length >= 2} >
    <translation-link each={ opts.translations }
      url={ url } path={ path } language={ language } title={ title }
      clickHandler={ visit } disabled={ opts.current == id } />
  </ul>
  <p if={ searchString && !filtered.length } class="notfound">
    Document not found.
  </p>
  <ul if={ searchString && filtered.length } >
    <translation-link each={ filtered }
      url={ url } language={ language } title={ title }
      clickHandler={ visit } />
  </ul>
  <footer>
    <button onclick={ reload } class="reload">
      <i class="fa fa-refresh"></i></button>
    TechDocs
  </footer>
  <style>
    popup > p {
      margin: 0;
      padding: 1em;
    }
    popup > ul {
      margin: 0;
      padding: .5em 0;
      list-style: none;
    }
    popup > header {
      border-bottom: 1px dotted #ddd;
      padding: .9em 1em .9em;
      color: #ccc;
      text-align: center;
    }
    popup > footer {
      border-top: 1px dotted #ddd;
      padding: .5em 1em .7em;
      color: #ccc;
      text-align: center;
    }
    popupreload {
      position: absolute;
      left: 1em;
      color: #999;
    }
    popup .reload:hover {
      color: #333;
    }
    popup .search {
      font-size: 1.4em;
      text-align: center;
      width: 100%;
    }
    popup .notfound {
      text-align: center;
      color: #999
    }
  </style>
  <script type="coffee-script">
    @searchstring = ''

    handleChange = (e) ->
      @searchString = e.target.value.trim().toLowerCase()
      return unless @searchString.length
      @filtered = opts.index
        .filter (sf) -> sf.id.replace(/\-\w\w$/, '').match @searchString
        .slice 0, 10

    click = (e) ->
      this.visit opts.contributingUrl

    visit = (url) ->
      chrome.tabs.update opts.tabId, url: url
      window.close()
  </script>
</popup>
