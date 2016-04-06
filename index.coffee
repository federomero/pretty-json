formatter = {}

formatter.space = ->
  editorSettings = atom.config.get 'editor'
  if editorSettings.softTabs?
    return Array(editorSettings.tabLength + 1).join ' '
  else
    return '\t'

formatter.stringify = (obj, sorted) ->
  # lazy load requirements
  JSONbig = require 'json-bigint'
  stringify = require 'json-stable-stringify'

  space = formatter.space()
  if sorted
    return stringify obj,
      space: space
  else
    return JSONbig.stringify obj, null, space

formatter.parseAndValidate = (text) ->
  JSONbig = require 'json-bigint' # lazy load requirements
  return JSONbig.parse text

formatter.pretty = (text, sorted) ->
  try
    space = formatter.space()
    parsed = formatter.parseAndValidate text
    return formatter.stringify parsed, sorted
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty: parse issue: #{error}"
    text

formatter.minify = (text) ->
  try
    uglify = require 'jsonminify' # lazy load requirements
    formatter.parseAndValidate text
    uglify text
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty: parse issue: #{error}"
    text

formatter.jsonify = (text, sorted) ->
  try
    vm = require 'vm' # lazy load requirements
    vm.runInThisContext("newObject = #{text};")
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty: eval issue: #{error}"
    text

  try
    return formatter.stringify newObject, sorted
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty: parse issue: #{error}"
    text

formatter.doEntireFile = (editor) ->
  grammars = atom.config.get('pretty-json.grammars') ? []
  return editor.getGrammar().scopeName in grammars

PrettyJSON =
  config:
    notifyOnParseError:
      type: 'boolean'
      default: true
    grammars:
      type: 'array'
      default: ['source.json', 'text.plain.null-grammar']

  prettify: (editor, sorted) ->
    if formatter.doEntireFile editor
      editor.setText formatter.pretty(editor.getText(), sorted)
    else
      editor.replaceSelectedText({}, (text) -> formatter.pretty text, sorted)

  minify: (editor) ->
    if formatter.doEntireFile editor
      editor.setText formatter.minify(editor.getText())
    else
      editor.replaceSelectedText({}, (text) -> formatter.minify text)

  jsonify: (editor, sorted) ->
    if formatter.doEntireFile editor
      editor.setText formatter.jsonify(editor.getText(), sorted)
    else
      editor.replaceSelectedText({}, (text) -> formatter.jsonify text)

  activate: ->
    atom.commands.add 'atom-workspace',
      'pretty-json:prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @prettify editor, false
      'pretty-json:minify': =>
        editor = atom.workspace.getActiveTextEditor()
        @minify editor
      'pretty-json:sort-and-prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @prettify editor, true
      'pretty-json:jsonify-literal-and-prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @jsonify editor, false
      'pretty-json:jsonify-literal-and-sort-and-prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @jsonify editor, false

module.exports = PrettyJSON
