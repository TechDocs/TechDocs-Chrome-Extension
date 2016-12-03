function createRegExp (str) {
  str = str
    .replace(/\$/g, '\\$')
    .replace(/\./g, '\\.')
    .replace(/\*/g, '(.+?)')
  return new RegExp(`^${str}$`)
}

function createReplacer (str, fs, direction) {
  return function () {
    const p = Array.from(arguments).slice(1, arguments.length - 1)
    const parts = str.split('*')
    const first = parts.shift()
    return parts.reduce((acc, part) => {
      return acc + filter(p.shift(), fs, direction) + part
    }, first)
  }
}

function filter (str, fs, direction) {
  return fs.reduce((acc, f) => {
    const args = f.split(/\s*:\s*/)
    const command = args.shift()
    switch (command) {
      case 'camel2snake': return camel2snake(acc, direction)
      case 'snake2camel': return camel2snake(acc, !direction)
      case 'dot2snake': return dot2snake(acc, direction)
      case 'snake2dot': return dot2snake(acc, !direction)
      case 'replace': return replace(acc, direction)
      default: return acc
    }
  }, str)
}

function camel2snake (str, direction) {
  return direction
    ? str.replace(/[A-Z]/g, match => '_' + match.toLowerCase())
    : str.replace(/_([a-z])/g, (match, p1) => p1.toUpperCase())
}

function dot2snake (str, direction) {
  return direction
    ? str.replace(/\./g, '_')
    : str.replace(/_/g, '.')
}

function replace (str, direction) {
  // TODO
}

export function convert (path, rules, reverseFlag = false) {
  if (!path || !rules) return ''
  for (const rule of rules) {
    const fs = rule.split(/\|/).map(v => v.trim())
    const found = fs.shift().match(/^(.+?)\s*(>|<)\s*(.+?)$/)
    if (found) {
      let direction = (found[2] === '>')
      if (reverseFlag) direction = !direction
      const from = direction ? found[1] : found[3]
      const to = direction ? found[3] : found[1]
      const re = createRegExp(from)
      if (re.test(path)) return path.replace(re, createReplacer(to, fs, direction))
    }
  }
  return ''
}

export function reverse (path, rules) { return convert(path, rules, true) }
