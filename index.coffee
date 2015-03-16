'use strict'

# Checkbox replacement logic.
#

checkbox_replace = (md) ->
  arrayReplaceAt = md.utils.arrayReplaceAt
  lastId = 0
  options =
    div_wrap: false
  pattern = /\[(X|\s|\_|\-)\]\s(.*)/i

  splitTextToken = (original,Token) ->
    text      = original.content
    last_pos  = 0
    nodes     = []
    matches   = text.match(pattern)
    value     = matches[1]
    label     = matches[2]

    checked = (value=='X' || value=='x') ? true : false

    ###*
    # <div class='checkbox'>
    ###
    if options.div_wrap
      token = new Token('checkbox_open', 'div', 1)
      token.attrs = [['class','checkbox']]
      nodes.push token

    ###*
    # <input type="checkbox" id="checkbox{n}" checked="true">
    ###
    id = 'checkbox'+lastId
    lastId += 1
    token = new Token('checkbox_input', 'input', 0)
    token.attrs = [['type','checkbox'],['id',id]]
    if(checked == true)
      token.attrs.push ['checked','true']
    nodes.push token

    ###*
    # <label for="checkbox{n}">
    ###
    token = new Token('label_open', 'label', 1)
    token.attrs = [['for',id]]
    nodes.push token

    ###*
    # content of label tag
    ###
    token = new Token('text', '', 0)
    token.content = label
    nodes.push token

    ###*
    # closing tags
    ###
    nodes.push new Token('label_close', 'label', -1)
    if options.div_wrap
      nodes.push new Token('checkbox_close', 'div', -1)

    return nodes


  checkbox_replace = (state)->
    blockTokens = state.tokens
    j = 0
    l = blockTokens.length
    while j < l
      if blockTokens[j].type != 'inline'
        j++
        continue
      tokens = blockTokens[j].children
      # We scan from the end, to keep position when new tags added.
      # Use reversed logic in links start/end match
      i = tokens.length - 1
      while i >= 0
        token = tokens[i]
        if token.type == 'text' and pattern.test(token.content)
          blockTokens[j].children = tokens = arrayReplaceAt(
            tokens, i, splitTextToken(token,state.Token)
          )
        i--
      j++
    return


module.exports = (md,options) ->
  conf = options or {}
  md.core.ruler.push 'checkbox', checkbox_replace(md)
  return
