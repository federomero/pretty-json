stringify = require("json-stable-stringify")

prettify = (editor, sorted) ->
  wholeFile = editor.getGrammar().name == 'JSON'

  if wholeFile
    text = editor.getText()
    editor.setText(formatter(text, sorted))
  else
    text = editor.replaceSelectedText({}, (text) ->
      formatter(text, sorted)
    )

formatter = (text, sorted) ->
  editorSettings = atom.config.getSettings().editor
  if editorSettings.softTabs?
    space = Array(editorSettings.tabLength + 1).join(" ")
  else
    space = "\t"

  try
    parsed = JSON.parse(text)
    if sorted
      return stringify(parsed, { space: space })
    else
      return JSON.stringify(parsed, null, space)
  catch error
    text

module.exports =
  activate: ->
    atom.workspaceView.command 'pretty-json:prettify', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      prettify(editor)
    atom.workspaceView.command 'pretty-json:sort-and-prettify', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      prettify(editor, true)
