createRegExp = (str) ->
  str = str.replace /\$/g, '\\$'
  str = str.replace /\./g, '\\.'
  str = str.replace /\*/g, '(.+?)'
  new RegExp "^#{str}$"

createReplacer = (str, fs, direction) ->
  ->
    p =
      arguments[i] for i in [1...(arguments.length-2)]
    arr = str.split '*'
    ret = arr[0]
    for i in [1...arr.length]
      ret += filter p[i-1], fs, direction
      ret += arr[i]
    ret

filter = (str, fs, direction) ->
  for f in fs
    args = f.split /\s*:\s*/
    command = args.shift()
    str = switch command
      when 'camel2snake' then f_camel2snake str, direction
      when 'snake2camel' then f_camel2snake str, !direction
      when 'dot2snake' then f_dot2snake str, direction
      when 'snake2dot' then f_dot2snake str, !direction
      when 'replace' then f_replace str, direction
      else str
  str

f_camel2snake = (str, direction) ->
  if direction
    str.replace /[A-Z]/g, (match) -> '_' + match.toLowerCase()
  else
    str.replace /_([a-z])/g, (match, p1) -> p1.toUpperCase()

f_dot2snake = (str, direction) ->
  if direction
    str.replace /\./g, '_'
  else
    str.replace /_/g, '.'

f_replace = (str, direction) ->
  # TODO

convert = (path, rules, reverseFlag = false) ->
  if rules
    for rule in rules
      fs = rule.split /\|/
      fs = fs.map (v) -> v.trim()
      fromTo = fs.shift()

      if found = fromTo.match /^(.+?)\s*(>|<)\s*(.+?)$/
        direction = (found[2] == '>')
        direction = !direction if reverseFlag
        from = if direction then found[1] else found[3]
        to = if direction then found[3] else found[1]

        re = createRegExp from

        #console.log path, re, fs, re.test path

        if re.test path
          return path.replace re, createReplacer to, fs, direction

  ''

convert.reverse = (path, rules) -> convert path, rules, true

module.exports = convert