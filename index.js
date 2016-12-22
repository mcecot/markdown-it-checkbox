var _, checkboxReplace;

_ = require('underscore');

Array.prototype.move = function(element, offset) {
  var index, newIndex, removedElement;
  index = this.indexOf(element);
  if (index < 0) {
    return index;
  }
  newIndex = index + offset;
  if (newIndex < 0) {
    newIndex = 0;
  }
  if (newIndex >= this.length) {
    newIndex = this.length - 1;
  }
  removedElement = this.splice(index, 1)[0];
  this.splice(newIndex, 0, removedElement);
  return newIndex;
};

checkboxReplace = function(md, options, Token) {
  "use strict";
  var arrayReplaceAt, createTokens, defaults, lastId, pattern, splitTextToken;
  arrayReplaceAt = md.utils.arrayReplaceAt;
  lastId = 0;
  defaults = {
    divWrap: false,
    divClass: 'checkbox',
    idPrefix: 'checkbox',
    readonly: false
  };
  options = _.extend(defaults, options);
  pattern = /\[(X|\s|\_|\-)\]\s(.*)/i;
  createTokens = function(checked, label, Token) {
    var id, nodes, token;
    nodes = [];

    /**
     * <div class="checkbox">
     */
    if (options.divWrap) {
      token = new Token("checkbox_open", "div", 1);
      token.attrs = [["class", options.divClass]];
      nodes.push(token);
    }

    /**
     * <input type="checkbox" id="checkbox{n}" checked="" readonly="">
     */
    id = options.idPrefix + lastId;
    lastId += 1;
    token = new Token("checkbox_input", "input", 0);
    token.attrs = [["type", "checkbox"], ["id", id]];
    if (checked === true) {
      token.attrs.push(["checked", ""]);
    }
    if (options.readonly) {
      token.attrs.push(["readonly", ""]);
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
    return nodes;
  };
  splitTextToken = function(original, Token) {
    var checked, label, matches, text, value;
    text = original.content;
    matches = text.match(pattern);
    if (matches === null) {
      return original;
    }
    checked = false;
    value = matches[1];
    label = matches[2];
    if (value === "X" || value === "x") {
      checked = true;
    }
    return createTokens(checked, label, Token);
  };
  return function(state) {
    var blockTokens, i, j, k, l, labelClose, labelOpens, len, mappedTokens, open, ref, ref1, suitableIdx, token, tokens;
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
    j = 0;
    l = blockTokens.length;
    while (j < l) {
      if (blockTokens[j].type !== "inline") {
        j++;
        continue;
      }
      tokens = blockTokens[j].children;
      mappedTokens = tokens.map(function(t, idx) {
        return {
          idx: idx,
          type: t.type,
          token: t
        };
      });
      suitableIdx = tokens.length - 1;
      labelOpens = mappedTokens.filter(function(t) {
        return t.type === 'label_open';
      });
      ref = labelOpens.reverse();
      for (k = 0, len = ref.length; k < len; k++) {
        open = ref[k];
        if (suitableIdx < 0) {
          suitableIdx = 0;
        }
        while ((ref1 = mappedTokens[suitableIdx].type) === 'softbreak' || ref1 === 'checkbox_close') {
          suitableIdx--;
        }
        labelClose = mappedTokens.find(function(t, idx) {
          return (open.idx < idx && idx <= suitableIdx) && t.type === 'label_close';
        });
        tokens.move(labelClose.token, suitableIdx - labelClose.idx);
        suitableIdx = open.idx - 2;
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
