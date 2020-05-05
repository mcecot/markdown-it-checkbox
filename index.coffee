_ = require 'underscore'

# Checkbox replacement logic.
#

checkboxReplace = (md, options, Token) ->
  "use strict"

  arrayReplaceAt = md.utils.arrayReplaceAt
  lastId = 0
  defaults =
    divWrap: false
    divClass: 'checkbox'
    idPrefix: 'checkbox'

  options = _.extend defaults, options
  # Split string into: textBefore checkboxValue textAfter:
  pattern = /(.*?)\s?\[(X|\s|\_|\-)\]\s?(.*)/i


  createTokens = (nodes, matches, Token) ->
    checked = (matches[2] == "X" || matches[2] == "x")
    label = matches[3] || ''
    # We recurse:
    matches = label.match(pattern)
    if matches != null
      label = matches[1]

    ###*
    # <div class="checkbox">
    ###
    if options.divWrap
      token = new Token("checkbox_open", "div", 1)
      token.attrs = [["class",options.divClass]]
      nodes.push token

    ###*
    # <input type="checkbox" id="checkbox{n}" checked="true">
    ###
    id = options.idPrefix + lastId
    lastId += 1
    token = new Token("checkbox_input", "input", 0)
    token.attrs = [["type","checkbox"],["id",id]]
    if(checked == true)
      token.attrs.push ["checked","true"]
    nodes.push token

    ###*
    # <label for="checkbox{n}">
    ###
    token = new Token("label_open", "label", 1)
    token.attrs = [["for",id]]
    nodes.push token

    ###*
    # content of label tag
    ###
    token = new Token("text", "", 0)
    token.content = label
    nodes.push token

    ###*
    # closing tags
    ###
    nodes.push new Token("label_close", "label", -1)
    if options.divWrap
      nodes.push new Token("checkbox_close", "div", -1)

    if(matches != null)
      createTokens(nodes, matches, Token)

  splitTextToken = (original, Token) ->
    matches = original.content.match(pattern)

    if matches == null
      return original

    nodes = []
    if matches[1] != null
      original.content = matches[1]
      nodes = [original]

    createTokens(nodes, matches, Token)
    return nodes


  return (state) ->
    blockTokens = state.tokens
    j = 0
    l = blockTokens.length
    while j < l
      if blockTokens[j].type != "inline"
        j++
        continue
      tokens = blockTokens[j].children
      # We scan from the end, to keep position when new tags added.
      # Use reversed logic in links start/end match
      i = tokens.length - 1
      while i >= 0
        token = tokens[i]
        blockTokens[j].children = tokens = arrayReplaceAt(
          tokens, i, splitTextToken(token, state.Token)
        )
        i--
      j++
    return

  return

###global module###
module.exports = (md, options) ->
  "use strict"
  md.core.ruler.push "checkbox", checkboxReplace(md, options)
  return
