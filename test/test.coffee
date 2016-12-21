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

    it 'should optionally wrap arround a div layer', (done) ->
      md = require('markdown-it')()
      md.use plugin, {divWrap: true}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<div class="checkbox">' +
        '<input type="checkbox" id="checkbox0" checked="">' +
        '<label for="checkbox0">test written</label>' +
        '</div>' +
        '</p>\n'
      done()

    it 'should optionally change class of div layer', (done) ->
      md = require('markdown-it')()
      md.use plugin, {divWrap: true, divClass: 'cb'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<div class="cb">' +
        '<input type="checkbox" id="checkbox0" checked="">' +
        '<label for="checkbox0">test written</label>' +
        '</div>' +
        '</p>\n'
      done()

    it 'should optionally change the id', (done) ->
      md = require('markdown-it')()
      md.use plugin, {idPrefix: 'cb'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<input type="checkbox" id="cb0" checked="">' +
        '<label for="cb0">test written</label>' +
        '</p>\n'
      done()

    it 'should optionally be readonly', (done) ->
      md = require('markdown-it')()
      md.use plugin, {readonly: true}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<input type="checkbox" id="checkbox0" checked="" readonly="">' +
        '<label for="checkbox0">test written</label>' +
        '</p>\n'
      done()
