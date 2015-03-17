# markdown-it-checkbox

[![Build Status](https://img.shields.io/travis/mcecot/markdown-it-checkbox/master.svg?style=flat)](https://travis-ci.org/mcecot/markdown-it-checkbox)
[![NPM version](https://img.shields.io/npm/v/markdown-it-checkbox.svg?style=flat)](https://www.npmjs.org/package/markdown-it-checkbox)
[![Coverage Status](https://img.shields.io/coveralls/mcecot/markdown-it-checkbox/master.svg?style=flat)](https://coveralls.io/r/markdown-it/markdown-it-checkbox)

> Plugin to create checkboxes for [markdown-it](https://github.com/markdown-it/markdown-it) markdown parser.

This plugin allows to create checkboxes for tasklists as discussed [here](http://talk.commonmark.org/t/task-lists-in-standard-markdown/41).

## Usage

## Install

node.js, browser:

```bash
npm install markdown-it-checkbox --save
bower install markdown-it-checkbox --save
```

## Use

```js
var md = require('markdown-it')()
            .use(require('markdown-it-checkbox'));

md.render('[ ] unchecked') // => '<p><mark>marked</mark></p>'
```

_Differences in browser._ If you load script directly into the page, without
package system, module will add itself globally as `window.markdownitCheckbox`.


## License

[MIT](https://github.com/markdown-it/markdown-it-for-inline/blob/master/LICENSE)
