'use strict'
path = require('path')
generate = require('markdown-it-testgen')
should = require 'should'

###eslint-env mocha ###
describe 'markdown-it-checkbox', ->

  describe 'markdown-it-checkbox()', ->
    plugin = require '../'
    md = require('markdown-it')()
    md.use plugin, {divWrap: false}
    generate path.join(__dirname, 'fixtures/checkbox.txt'), md

    it 'should pass irrelevant markdown', (done) ->
      res = md.render('# test')
      res.toString().should.be.eql '<h1>test</h1>\n'
      done()

  describe 'markdown-it-checkbox(options)', ->
    plugin = require('../')

    it 'should should optionally wrap arround a div layer', (done) ->
      md = require('markdown-it')()
      md.use plugin, {divWrap: true}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<div class="checkbox">' +
        '<input type="checkbox" id="checkbox0" checked="true">' +
        '<label for="checkbox0">test written</label>' +
        '</div>' +
        '</p>\n'
      done()

    it 'should should optionally change class of div layer', (done) ->
      md = require('markdown-it')()
      md.use plugin, {divWrap: true, divClass: 'cb'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<div class="cb">' +
        '<input type="checkbox" id="checkbox0" checked="true">' +
        '<label for="checkbox0">test written</label>' +
        '</div>' +
        '</p>\n'
      done()

    it 'should should optionally change the id', (done) ->
      md = require('markdown-it')()
      md.use plugin, {idPrefix: 'cb'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<input type="checkbox" id="cb0" checked="true">' +
        '<label for="cb0">test written</label>' +
        '</p>\n'
      done()

    it 'should render a checkbox when it is a the end of a line', (done) ->
      md = require('markdown-it')()
      md.use plugin, {idPrefix: 'cb'}
      res = md.render('[ ]')
      res.toString().should.be.eql '<p>' +
        '<input type="checkbox" id="cb0">' +
        '<label for="cb0"></label>' +
        '</p>\n'
      done()

    it 'should preserve text before & after', (done) ->
      md = require('markdown-it')()
      md.use plugin, {idPrefix: 'cb'}
      res = md.render('before [ ] after')
      res.toString().should.be.eql '<p>' +
        'before<input type="checkbox" id="cb0">' +
        '<label for="cb0">after</label>' +
        '</p>\n'
      done()

    it 'should render two consecutive checkboxes', (done) ->
      md = require('markdown-it')()
      md.use plugin, {idPrefix: 'cb'}
      res = md.render('[ ] one [ ] two')
      res.toString().should.be.eql '<p>' +
        '<input type="checkbox" id="cb0">' +
        '<label for="cb0">one</label>' +
        '<input type="checkbox" id="cb1">' +
        '<label for="cb1">two</label>' +
        '</p>\n'
      done()

    it 'should render indented checkboxes', (done) ->
      md = require('markdown-it')()
      md.use plugin, {idPrefix: 'cb'}
      res = md.render('- [ ] 1\n- [ ] 2\n  - [ ] 3')
      res.toString().should.be.eql '<ul>\n' +
      '<li><input type="checkbox" id="cb0"><label for="cb0">1</label></li>\n' +
      '<li><input type="checkbox" id="cb1"><label for="cb1">2</label>\n' +
      '<ul>\n' +
      '<li><input type="checkbox" id="cb2"><label for="cb2">3</label></li>\n' +
      '</ul>\n' +
      '</li>\n' +
      '</ul>\n'
      done()
