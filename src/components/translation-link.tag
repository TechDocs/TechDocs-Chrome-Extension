<translation-link>

  <a if={ clickable } href="#" onclick={ click } >
    <span class="language">{ opts.language }</span>
    { opts.title }
  </a>
  <div if={ !clickable } class="disabled">
    <span class="language">{ opts.language }</span>
    { opts.title }
  </div>

  <script>
    this.clickable = opts.clickable === true || opts.clickable !== false
    this.click = e => {
      e.preventDefault()
      opts.handler(opts.url + (opts.path || ''))
    }
  </script>

  <style>
    a, div {
      display: block;
      color: inherit;
      white-space: nowrap;
      line-height: 2em;
      text-overflow: ellipsis;
      overflow: hidden;
      padding: 0 1em;
    }
    a:hover {
      background: rgba(0,0,0,.1);
    }
    .disabled {
      opacity: .3;
    }
    .language {
      background: #FB1C1C;
      color: #fff;
      text-align: center;
      width: 2em;
      line-height: 1.4em;
      border-radius: .6em;
      margin-right: .1em;
      display: inline-block;
      font-size: 90%;
    }
  </style>

</translation-link>
