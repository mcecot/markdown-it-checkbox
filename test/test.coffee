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
        '<input type="checkbox" id="checkbox0" checked="">' +
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
        '<input type="checkbox" id="checkbox0" checked="">' +
        '<label for="checkbox0">test written</label>' +
        '</div>' +
        '</p>\n'
      done()

    it 'should should optionally change the id', (done) ->
      md = require('markdown-it')()
      md.use plugin, {idPrefix: 'cb'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<input type="checkbox" id="cb0" checked="">' +
        '<label for="cb0">test written</label>' +
        '</p>\n'
      done()

    it 'should should optionally add disabled attribute', (done) ->
      md = require('markdown-it')()
      md.use plugin, {disabled: true}
      res = md.render('[X] test written')
      res.toString().should.be.eql '<p>' +
        '<input type="checkbox" id="checkbox0" checked="" disabled="">' +
        '<label for="checkbox0">test written</label>' +
        '</p>\n'
      done()

    it 'should apply custom html', (done) ->
      md = require('markdown-it')()
      md.use plugin, {disabled: true, customHTML: '
        <div class="checklist-item">\
          <div class="checklist-item__checkbox">\
            <input type="checkbox">\
          </div>\
           <label class="checklist-item__label"\
           >test written2</label>\
          <label class="checklist-item__label">\
          {label}\
          </label>\
        </div>'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '
        <p><div class="checklist-item">\
          <div class="checklist-item__checkbox">\
            <input disabled="" checked="" \
            id="checkbox0" type="checkbox">\
          </div>\
            <label class="checklist-item__label"\
            >test written2</label>\
            <label for="checkbox0" class="checklist-item__label"\
            >test written</label>\
        </div></p>\n'
      done()

    it 'custom html without label tag', (done) ->
      md = require('markdown-it')()
      md.use plugin, {disabled: true, customHTML: '
        <div class="checklist-item">\
          <div class="checklist-item__checkbox">\
            <input type="checkbox">\
          </div>\
        </div>'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '
        <p><div class="checklist-item">\
          <div class="checklist-item__checkbox">\
            <input disabled="" checked="" \
            id="checkbox0" type="checkbox">\
          </div>\
        </div></p>\n'
      done()

    it 'custom html without input tag', (done) ->
      md = require('markdown-it')()
      md.use plugin, {disabled: true, customHTML: '
      <div class="checklist-item">\
        <div class="checklist-item__checkbox">\
        </div>\
        <label class="checklist-item__label">\
        </label>\
      </div>'}
      res = md.render('[X] test written')
      res.toString().should.be.eql '
      <p><div class="checklist-item">\
        <div class="checklist-item__checkbox">\
        </div>\
        <label for="checkbox0" class="checklist-item__label"\
        >test written</label>\
      </div></p>\n'
      done()
