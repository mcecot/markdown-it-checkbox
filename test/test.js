"use strict";
var path      = require('path');
var generate  = require('markdown-it-testgen');

/*eslint-env mocha */
describe("markdown-it-checkbox", function() {
  var md;
  md = require("markdown-it")().use(require("../build"));
  generate(path.join(__dirname, "fixtures/checkbox.txt"), md);
});
