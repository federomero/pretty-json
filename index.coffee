stringify = require("json-stable-stringify")
uglify = require("jsonminify")
formatter = {}

prettify = (editor, sorted) ->
  wholeFile = editor.getGrammar().name == 'JSON'

  if wholeFile
    text = editor.getText()
    editor.setText(formatter.pretty(text, sorted))
  else
    text = editor.replaceSelectedText({}, (text) ->
      formatter.pretty(text, sorted)
    )

minify = (editor, sorted) ->
  wholeFile = editor.getGrammar().name == 'JSON'

  if wholeFile
    text = editor.getText()
    editor.setText(formatter.minify(text))
  else
    text = editor.replaceSelectedText({}, (text) ->
      formatter.minify(text);
    )

formatter.pretty = (text, sorted) ->
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

formatter.minify = (text) ->
  try
    JSON.parse(text)
    uglify(text);
  catch error
    text;

module.exports =
  activate: ->
    atom.commands.add 'atom-workspace',
      'pretty-json:prettify': ->
        editor = atom.workspace.getActiveTextEditor()
        prettify(editor)
      'pretty-json:sort-and-prettify': ->
        editor = atom.workspace.getActiveTextEditor()
        prettify(editor, true)
      'pretty-json:minify': ->
        editor = atom.workspace.getActiveTextEditor()
        minify(editor, true)
