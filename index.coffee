formatter = {}
JSONbig = require 'json-bigint'

formatter.pretty = (text, sorted) ->
  editorSettings = atom.config.get 'editor'
  if editorSettings.softTabs?
    space = Array(editorSettings.tabLength + 1).join ' '
  else
    space = '\t'

  try
    parsed = JSONbig.parse(text)
    if sorted
      stringify = require 'json-stable-stringify'
      return stringify parsed,
        space: space
    else
      return JSONbig.stringify parsed, null, space
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty parse issue: #{error}"
    text

formatter.minify = (text) ->
  try
    JSONbig.parse text
    uglify = require 'jsonminify'
    uglify text
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty parse issue: #{error}"
    text

formatEntireFile = (editor) ->
  grammars = atom.config.get('pretty-json.grammars') ? ['source.json']
  return editor.getGrammar().scopeName in grammars

module.exports =
  config:
    notifyOnParseError:
      type: 'boolean'
      default: true
    grammars:
      type: 'array'
      default: ['source.json', 'text.plain.null-grammar']

  prettify: (editor, sorted) ->
    if formatEntireFile(editor)
      editor.setText formatter.pretty(editor.getText(), sorted)
    else
      editor.replaceSelectedText({}, (text) -> formatter.pretty text, sorted)

  minify: (editor, sorted) ->
    if formatEntireFile(editor)
      editor.setText formatter.minify(editor.getText())
    else
      editor.replaceSelectedText({}, (text) -> formatter.minify text)

  activate: ->
    atom.commands.add 'atom-workspace',
      'pretty-json:prettify': ->
        editor = atom.workspace.getActiveTextEditor()
        prettify editor
      'pretty-json:sort-and-prettify': ->
        editor = atom.workspace.getActiveTextEditor()
        prettify editor, true
      'pretty-json:minify': ->
        editor = atom.workspace.getActiveTextEditor()
        minify editor, true
