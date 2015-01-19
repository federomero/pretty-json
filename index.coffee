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
  editorSettings = atom.config.get('editor')
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
    atom.commands.add 'atom-workspace',
      'pretty-json:prettify': ->
        editor = atom.workspace.getActiveEditor()
        prettify(editor)
      'pretty-json:sort-and-prettify': ->
        editor = atom.workspace.getActiveEditor()
        prettify(editor, true)
