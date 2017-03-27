{CompositeDisposable} = require 'atom'
formatter = {}

formatter.space = (scope) ->
  softTabs = [atom.config.get 'editor.softTabs', scope: scope]
  tabLength = Number [atom.config.get 'editor.tabLength', scope: scope]
  if softTabs?
    return Array(tabLength + 1).join ' '
  else
    return '\t'

formatter.stringify = (obj, options) ->
  scope = if options?.scope? then options.scope else null
  sorted = if options?.sorted? then options.sorted else false

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

formatter.pretty = (text, options) ->
  try
    parsed = formatter.parseAndValidate text
  catch error
    return text
  return formatter.stringify parsed, options

formatter.minify = (text) ->
  try
    formatter.parseAndValidate text
  catch error
    return text
  uglify = require 'jsonminify' # lazy load requirements
  return uglify text

formatter.jsonify = (text, options) ->
  vm = require 'vm' # lazy load requirements
  try
    vm.runInThisContext "newObject = #{text};"
  catch error
    if atom.config.get 'pretty-json.notifyOnParseError'
      atom.notifications.addWarning "JSON Pretty: eval issue: #{error}"
    return text
  return formatter.stringify newObject, options

PrettyJSON =
  config:
    notifyOnParseError:
      type: 'boolean'
      default: true
    prettifyOnSaveJSON:
      type: 'boolean'
      default: false
      title: 'Prettify On Save JSON'
    grammars:
      type: 'array'
      default: ['source.json', 'text.plain.null-grammar']

  doEntireFile: (editor) ->
    grammars = atom.config.get 'pretty-json.grammars' ? []
    if editor?.getGrammar().scopeName not in grammars
      return false
    return editor.getLastSelection().isEmpty()

  replaceText: (editor, fn) ->
    editor.mutateSelectedText (selection) ->
      selection.getBufferRange()
      text = selection.getText()
      selection.deleteSelectedText()
      range = selection.insertText fn text
      selection.setBufferRange range

  prettify: (editor, options) ->
    return unless editor?
    entire = if options?.entire? then options.entire else @doEntireFile editor
    sorted = if options?.sorted? then options.sorted else false
    selected = if options?.selected? then options.selected else true
    if entire
      pos = editor.getCursorScreenPosition()
      editor.setText formatter.pretty editor.getText(),
        scope: editor.getRootScopeDescriptor()
        sorted: sorted
    else
      pos = editor.getLastSelection().getScreenRange().start
      @replaceText editor, (text) -> formatter.pretty text,
        scope: ['source.json']
        sorted: sorted
    unless selected
      editor.setCursorScreenPosition pos

  minify: (editor, options) ->
    entire = if options?.entire? then options.entire else @doEntireFile editor
    selected = if options?.selected? then options.selected else true
    if entire
      pos = [0, 0]
      editor.setText formatter.minify editor.getText()
    else
      pos = editor.getLastSelection().getScreenRange().start
      @replaceText editor, (text) -> formatter.minify text
    unless selected
      editor.setCursorScreenPosition pos

  jsonify: (editor, options) ->
    entire = if options?.entire? then options.entire else @doEntireFile editor
    sorted = if options?.sorted? then options.sorted else false
    selected = if options?.selected? then options.selected else true
    if entire
      pos = editor.getCursorScreenPosition()
      editor.setText formatter.jsonify editor.getText(),
        scope: editor.getRootScopeDescriptor()
        sorted: sorted
    else
      pos = editor.getLastSelection().getScreenRange().start
      @replaceText editor, (text) -> formatter.jsonify text,
        scope: ['source.json']
        sorted: sorted
    unless selected
      editor.setCursorScreenPosition pos

  activate: ->
    atom.commands.add 'atom-workspace',
      'pretty-json:prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @prettify editor,
          entire: @doEntireFile editor
          sorted: false
          selected: true
      'pretty-json:minify': =>
        editor = atom.workspace.getActiveTextEditor()
        @minify editor,
          entire: @doEntireFile editor
          selected: true
      'pretty-json:sort-and-prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @prettify editor,
          entire: @doEntireFile editor
          sorted: true
          selected: true
      'pretty-json:jsonify-literal-and-prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @jsonify editor,
          entire: @doEntireFile editor
          sorted: false
          selected: true
      'pretty-json:jsonify-literal-and-sort-and-prettify': =>
        editor = atom.workspace.getActiveTextEditor()
        @jsonify editor,
          entire: @doEntireFile editor
          sorted: true
          selected: true

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'pretty-json.prettifyOnSaveJSON', (value) =>
      @saveSubscriptions?.dispose()
      @saveSubscriptions = new CompositeDisposable()
      if value
        @subscribeToSaveEvents()

  subscribeToSaveEvents: ->
    @saveSubscriptions.add atom.workspace.observeTextEditors (editor) =>
      return if not editor?.getBuffer()
      bufferSubscriptions = new CompositeDisposable()
      bufferSubscriptions.add editor.getBuffer().onWillSave (filePath) =>
        if @doEntireFile editor
          @prettify editor,
            entire: true
            sorted: false
            selected: false
      bufferSubscriptions.add editor.getBuffer().onDidDestroy ->
        bufferSubscriptions.dispose()
      @saveSubscriptions.add bufferSubscriptions

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

module.exports = PrettyJSON
