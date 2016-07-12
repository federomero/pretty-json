formatter = {}

formatter.space = (scope) ->
  softTabs = [atom.config.get 'editor.softTabs', scope: scope]
  tabLength = Number([atom.config.get 'editor.tabLength', scope: scope])
  if softTabs?
    return Array(tabLength + 1).join ' '
  else
    return '\t'

formatter.stringify = (obj, scope, sorted) ->
  # lazy load requirements
  JSONbig = require 'json-bigint'
  stringify = require 'json-stable-stringify'
  BigNumber = require 'bignumber.js'

  space = formatter.space scope
  if sorted
    return stringify obj,
      space: space
      replacer: (key, value) ->
        try
          if value.constructor.name is 'BigNumber'
            return JSONbig.stringify value
        catch
          # ignore
        return value
  else
    return JSONbig.stringify obj, null, space

formatter.parseAndValidate = (text) ->
  JSONbig = require 'json-bigint' # lazy load requirements
  try
    return JSONbig.parse text
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty: #{error.name}: #{error.message} at character #{error.at} near \"#{error.text}\""
    throw error

formatter.pretty = (text, scope, sorted) ->
  try
    parsed = formatter.parseAndValidate text
  catch error
    return text
  return formatter.stringify parsed, scope, sorted

formatter.minify = (text) ->
  try
    formatter.parseAndValidate text
  catch error
    return text
  uglify = require 'jsonminify' # lazy load requirements
  return uglify text

formatter.jsonify = (text, scope, sorted) ->
  vm = require 'vm' # lazy load requirements
  try
    vm.runInThisContext("newObject = #{text};")
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty: eval issue: #{error}"
    return text
  return formatter.stringify newObject, scope, sorted

formatter.doEntireFile = (editor) ->
  if not editor.getLastSelection().isEmpty()
    return false
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

  replaceText: (editor, fn) ->
    editor.mutateSelectedText (selection) ->
      selection.getBufferRange()
      text = selection.getText()
      selection.deleteSelectedText()
      range = selection.insertText(fn(text))
      selection.setBufferRange(range)

  prettify: (editor, sorted) ->
    if formatter.doEntireFile editor
      editor.setText formatter.pretty(editor.getText(), editor.getRootScopeDescriptor(), sorted)
    else
      @replaceText editor, (text) -> formatter.pretty text, ['source.json'], sorted

  minify: (editor) ->
    if formatter.doEntireFile editor
      editor.setText formatter.minify(editor.getText())
    else
      @replaceText editor, (text) -> formatter.minify text

  jsonify: (editor, sorted) ->
    if formatter.doEntireFile editor
      editor.setText formatter.jsonify(editor.getText(), editor.getRootScopeDescriptor(), sorted)
    else
      @replaceText editor, (text) -> formatter.jsonify text, ['source.json'], sorted

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
        @jsonify editor, true

module.exports = PrettyJSON
