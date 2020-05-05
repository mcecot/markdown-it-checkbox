var _, checkboxReplace;

_ = require('underscore');

checkboxReplace = function(md, options, Token) {
  "use strict";
  var arrayReplaceAt, createTokens, defaults, lastId, pattern, splitTextToken;
  arrayReplaceAt = md.utils.arrayReplaceAt;
  lastId = 0;
  defaults = {
    divWrap: false,
    divClass: 'checkbox',
    idPrefix: 'checkbox'
  };
  options = _.extend(defaults, options);
  pattern = /(.*?)\s?\[(X|\s|\_|\-)\]\s?(.*)/i;
  createTokens = function(nodes, matches, Token) {
    var checked, id, label, token;
    checked = matches[2] === "X" || matches[2] === "x";
    label = matches[3] || '';
    matches = label.match(pattern);
    if (matches !== null) {
      label = matches[1];
    }

    /**
     * <div class="checkbox">
     */
    if (options.divWrap) {
      token = new Token("checkbox_open", "div", 1);
      token.attrs = [["class", options.divClass]];
      nodes.push(token);
    }

    /**
     * <input type="checkbox" id="checkbox{n}" checked="true">
     */
    id = options.idPrefix + lastId;
    lastId += 1;
    token = new Token("checkbox_input", "input", 0);
    token.attrs = [["type", "checkbox"], ["id", id]];
    if (checked === true) {
      token.attrs.push(["checked", "true"]);
    }
    nodes.push(token);

    /**
     * <label for="checkbox{n}">
     */
    token = new Token("label_open", "label", 1);
    token.attrs = [["for", id]];
    nodes.push(token);

    /**
     * content of label tag
     */
    token = new Token("text", "", 0);
    token.content = label;
    nodes.push(token);

    /**
     * closing tags
     */
    nodes.push(new Token("label_close", "label", -1));
    if (options.divWrap) {
      nodes.push(new Token("checkbox_close", "div", -1));
    }
    if (matches !== null) {
      return createTokens(nodes, matches, Token);
    }
  };
  splitTextToken = function(original, Token) {
    var matches, nodes;
    matches = original.content.match(pattern);
    if (matches === null) {
      return original;
    }
    nodes = [];
    if (matches[1] !== null) {
      original.content = matches[1];
      nodes = [original];
    }
    createTokens(nodes, matches, Token);
    return nodes;
  };
  return function(state) {
    var blockTokens, i, j, l, token, tokens;
    blockTokens = state.tokens;
    j = 0;
    l = blockTokens.length;
    while (j < l) {
      if (blockTokens[j].type !== "inline") {
        j++;
        continue;
      }
      tokens = blockTokens[j].children;
      i = tokens.length - 1;
      while (i >= 0) {
        token = tokens[i];
        blockTokens[j].children = tokens = arrayReplaceAt(tokens, i, splitTextToken(token, state.Token));
        i--;
      }
      j++;
    }
  };
};


/*global module */

module.exports = function(md, options) {
  "use strict";
  md.core.ruler.push("checkbox", checkboxReplace(md, options));
};
