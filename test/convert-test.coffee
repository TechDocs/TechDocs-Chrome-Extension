jest.dontMock '../src/coffee/lib/convert.coffee'

describe 'convert', ->

  it 'converts aaa to bbb', ->
    convert = require '../src/coffee/lib/convert.coffee'
    expect convert 'aaa', ['aaa > bbb']
    .toBe 'bbb'

  it 'converts abc/ to abc.html', ->
    convert = require '../src/coffee/lib/convert.coffee'
    expect convert 'abc/', ['*/ > *.html']
    .toBe 'abc.html'

  it 'converts camelCase to snake_case', ->
    convert = require '../src/coffee/lib/convert.coffee'
    expect convert 'aaaBbbCcc.html', ['*.html > *.html | camel2snake']
    .toBe 'aaa_bbb_ccc.html'

  it 'converts snake_case to camelCase', ->
    convert = require '../src/coffee/lib/convert.coffee'
    expect convert 'aaa_bbb_ccc.html', ['*.html > *.html | snake2camel']
    .toBe 'aaaBbbCcc.html'

  it 'converts dot.case to snake_case', ->
    convert = require '../src/coffee/lib/convert.coffee'
    expect convert 'x/aaa.bbb.ccc/', ['x/*/ > y/*/ | dot2snake']
    .toBe 'y/aaa_bbb_ccc/'

  it 'converts snake_case to dot.case', ->
    convert = require '../src/coffee/lib/convert.coffee'
    expect convert 'x/aaa_bbb_ccc/', ['x/*/ > y/*/ | snake2dot']
    .toBe 'y/aaa.bbb.ccc/'

