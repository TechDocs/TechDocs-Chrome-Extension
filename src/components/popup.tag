<popup>

  <header>
    <input
      class="search"
      type="search"
      placeholder={ opts.title }
      value={ searchString }
      onkeyup={ handleChange }>
  </header>
  <p if={ !searchString && tLength == 0}>
    Is this a technical document?<br>
    <a href="#" onclick={ visit } >Let's make PR to add it to TechDocs!</a>
  </p>
  <p if={ !searchString && tLength == 1}>
    This document is already registered. Do you know the translation for it?<br>
    <a href="#" onclick={ visit } >Let's make PR to add it to TechDocs!</a>
  </p>
  <ul if={ !searchString && tLength >= 2}>
    <li data-is="translation-link" each={ translations }
      url={ url }
      path={ path }
      language={ language }
      title={ title }
      clickable={ clickable }></li>
  </ul>
  <p if={ searchString && !fLength } class="notfound">
    Document not found.
  </p>
  <ul if={ searchString && fLength }>
    <li data-is="translation-link" each={ filtered }
      url={ url }
      language={ language }
      title={ title }></li>
  </ul>
  <footer>
    <button onclick={ gohome } class="reload">
      <i class="fa fa-home"></i></button>
    TechDocs
  </footer>

  <script>
    this.translations = opts.translations.map(t => Object.assign(t, { clickable: t.id !== opts.current }))
    this.tLength = this.translations.length
    this.fLength = 0
    this.searchString = ''
    this.filtered = []

    this.visit = url => {
      chrome.tabs.update(opts.tabId, {url})
      window.close()
    }

    this.handleChange = e => {
      e.preventDefault()
      this.searchString = e.target.value.trim().toLowerCase()
      if (!this.searchString.length) return
      this.filtered = opts.index
        .filter(sf => sf.id.replace(/-\w\w$/, '').match(this.searchString))
        .slice(0, 10)
      this.fLength = this.filtered.length
    }

    this.click = e => {
      e.preventDefault()
      this.visit(opts.contributingUrl)
    }

    this.gohome = e => {
      e.preventDefault()
      this.visit(opts.homeUrl)
    }
  </script>

  <style>
    :scope {
      display: block;
      --border-color: #ddd;
    }
    p {
      margin: 0;
      padding: 1em;
    }
    ul {
      margin: 0;
      padding: .5em 0;
      list-style: none;
    }
    :scope > header {
      border-bottom: 1px dotted var(--border-color);
      padding: .9em 1em .9em;
      color: #ccc;
      text-align: center;
    }
    :scope > footer {
      border-top: 1px dotted var(--border-color);
      padding: .5em 1em .7em;
      color: #ccc;
      text-align: center;
    }
    .reload {
      position: absolute;
      left: 1em;
      color: #999;
    }
    .reload:hover {
      color: #333;
    }
    .search {
      font-size: 1.4em;
      text-align: center;
      width: 100%;
    }
    .notfound {
      text-align: center;
      color: #999;
    }
  </style>

</popup>
