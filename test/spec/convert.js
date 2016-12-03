/* eslint-env mocha */
'use strict'
const assert = require('assert')
const convert = require('../../src/lib/convert').convert

describe('convert', () => {
  it('converts aaa to bbb', () => {
    assert.equal(convert('aaa', ['aaa > bbb']), 'bbb')
  })

  it('converts abc/ to abc.html', () => {
    assert.equal(convert('abc/', ['*/ > *.html']), 'abc.html')
  })

  it('converts camelCase to snake_case', () => {
    assert.equal(convert('aaaBbbCcc.html', ['*.html > *.html | camel2snake']), 'aaa_bbb_ccc.html')
  })

  it('converts snake_case to camelCase', () => {
    assert.equal(convert('aaa_bbb_ccc.html', ['*.html > *.html | snake2camel']), 'aaaBbbCcc.html')
  })

  it('converts dot.case to snake_case', () => {
    assert.equal(convert('x/aaa.bbb.ccc/', ['x/*/ > y/*/ | dot2snake']), 'y/aaa_bbb_ccc/')
  })

  it('converts snake_case to dot.case', () => {
    assert.equal(convert('x/aaa_bbb_ccc/', ['x/*/ > y/*/ | snake2dot']), 'y/aaa.bbb.ccc/')
  })
})
