<translation-link>
  <li>
    <a if={ !opts.disabled } href="#" onclick={ click } >
      <span class="language">{ opts.language }</span>
      { opts.title }
    </a>
    <div if={ opts.disabled } class="disabled">
      <span class="language">{ opts.language }</span>
      { opts.title }
    </div>
  </li>
  <style>
    translation-link > a,
    translation-link > div {
      display: block;
      color: inherit;
      white-space: nowrap;
      line-height: 2em;
      text-overflow: ellipsis;
      overflow: hidden;
      padding: 0 1em;
    }
    translation-link > a:hover {
      background: rgba(0,0,0,.1);
    }
    translation-link .disabled {
      opacity: .3;
    }
    translation-link .language {
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
  <script type="coffee-script">
    click = (e) ->
      opts.clickHandler opts.url + (opts.path || '')
  </script>
</translation-link>
