var checkboxReplace;

checkboxReplace = function(md, options, Token) {
  "use strict";
  var arrayReplaceAt, createTokens, defaults, lastId, pattern, splitTextToken;
  arrayReplaceAt = md.utils.arrayReplaceAt;
  lastId = 0;
  defaults = {
    divWrap: false,
    divClass: 'checkbox',
    idPrefix: 'checkbox',
    disabled: false,
    customHTML: false
  };
  options = Object.assign({}, defaults, options);
  pattern = /\[(X|\s|\_|\-)\]\s(.*)/i;
  createTokens = function(checked, label, Token) {
    var attr, customHTML, disabled, getTag, id, inputTag, labelTag, newInputTag, newLabelTag, nodes, token;
    nodes = [];
    id = options.idPrefix + lastId;
    lastId += 1;
    if (options.customHTML) {
      token = new Token("html_inline", "", 0);
      customHTML = options.customHTML, disabled = options.disabled;
      getTag = function(str, tagName, content) {
        var matches, regexp, res;
        if (content == null) {
          content = '';
        }
        regexp = new RegExp("(<" + tagName + ".*?>)(" + content + ")?", "igm");
        res = regexp.exec(str);
        if (!res) {
          return res;
        }
        while (matches = regexp.exec(str)) {
          if (~matches.indexOf(content) && content.length) {
            res = matches;
          }
        }
        return res[0];
      };
      attr = function(tag, attributes) {
        var addAttr, attrName, attrRegexp, attrValue, replaceAttr;
        if (attributes == null) {
          attributes = {};
        }
        replaceAttr = function(regexp, value) {
          return tag.replace(regexp, "$1" + value + "$2");
        };
        addAttr = function(attr, val) {
          var regexp, tagName;
          tagName = tag.match(/<(\w+?)\s/)[1];
          regexp = new RegExp("(<" + tagName + ")(.+?>)");
          if (val === true) {
            val = "";
          }
          return tag.replace(regexp, "$1 " + attr + "=\"" + val + "\"$2");
        };
        for (attrName in attributes) {
          attrValue = attributes[attrName];
          attrRegexp = new RegExp("(" + attrName + "=['\"]).+?(['\"])");
          if (attrValue === false) {
            continue;
          }
          if (~tag.search(attrRegexp)) {
            tag = replaceAttr(attrRegexp, attrValue);
          } else {
            tag = addAttr(attrName, attrValue);
          }
        }
        return tag;
      };
      labelTag = getTag(customHTML, 'label', '{label}');
      inputTag = getTag(customHTML, 'input');
      if (labelTag) {
        newLabelTag = attr(labelTag, {
          'for': id
        });
        if (~newLabelTag.search('{label}')) {
          newLabelTag = newLabelTag.replace('{label}', label);
          customHTML = customHTML.replace(labelTag, newLabelTag);
        } else {
          customHTML = customHTML.replace(/<label.*?>/, newLabelTag + label);
        }
      }
      if (inputTag) {
        newInputTag = attr(inputTag, {
          id: id,
          checked: checked,
          disabled: disabled
        });
        customHTML = customHTML.replace(/<input.+?>/, newInputTag);
      }
      token.content = customHTML;
      nodes.push(token);
      return nodes;
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
    token = new Token("checkbox_input", "input", 0);
    token.attrs = [["type", "checkbox"], ["id", id]];
    if (checked === true) {
      token.attrs.push(["checked", ""]);
    }
    if (options.disabled) {
      token.attrs.push(["disabled", ""]);
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
