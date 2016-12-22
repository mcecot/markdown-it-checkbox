# Utility functions
_ = require 'underscore'

Array.prototype.move = (element, offset) ->
  index = this.indexOf(element)
  # if not found, return immediately
  return index if index < 0

  newIndex = index + offset
  newIndex = 0 if newIndex < 0
  newIndex = this.length - 1 if newIndex >= this.length

  # remove the element from the array
  removedElement = this.splice(index, 1)[0]
  # at newIndex, remove 0 elements, insert the removedElement
  this.splice newIndex, 0, removedElement
  #return the newIndex of the removedElement
  return newIndex

# Checkbox replacement logic.
checkboxReplace = (md, options, Token) ->
  "use strict"

  arrayReplaceAt = md.utils.arrayReplaceAt
  lastId = 0
  defaults =
    divWrap: false
    divClass: 'checkbox'
    idPrefix: 'checkbox'
    readonly: false

  options = _.extend defaults, options
  pattern = /\[(X|\s|\_|\-)\]\s(.*)/i


  createTokens = (checked, label, Token) ->
    nodes = []
    ###*
    # <div class="checkbox">
    ###
    if options.divWrap
      token = new Token("checkbox_open", "div", 1)
      token.attrs = [["class",options.divClass]]
      nodes.push token

    ###*
    # <input type="checkbox" id="checkbox{n}" checked="" readonly="">
    ###
    id = options.idPrefix + lastId
    lastId += 1
    token = new Token("checkbox_input", "input", 0)
    token.attrs = [["type","checkbox"],["id",id]]
    if(checked == true)
      token.attrs.push ["checked", ""]
    if options.readonly
      token.attrs.push ["readonly", ""]
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

    return nodes

  splitTextToken = (original, Token) ->

    text      = original.content
    matches   = text.match pattern

    if matches == null
      return original

    checked   = false
    value     = matches[1]
    label     = matches[2]

    if (value == "X" || value == "x")
      checked = true

    return createTokens(checked, label, Token)


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

    j = 0
    l = blockTokens.length
    while j < l
      if blockTokens[j].type != "inline"
        j++
        continue
      tokens = blockTokens[j].children
      mappedTokens = tokens.map (t, idx) -> {
        idx: idx
        type: t.type
        token: t
      }
      suitableIdx = tokens.length - 1

      labelOpens = mappedTokens.filter (t) -> t.type is 'label_open'
      for open in labelOpens.reverse()
        if suitableIdx < 0 then suitableIdx = 0
        while mappedTokens[suitableIdx].type in ['softbreak','checkbox_close']
          suitableIdx--

        labelClose = mappedTokens.find (t, idx) ->
          open.idx < idx <= suitableIdx && t.type is 'label_close'
        tokens.move labelClose.token, suitableIdx - labelClose.idx

        suitableIdx = open.idx - 2
      j++
    return

  return

###global module###
module.exports = (md, options) ->
  "use strict"
  md.core.ruler.push "checkbox", checkboxReplace(md, options)
  return
