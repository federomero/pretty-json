prettify = (editor) ->
  wholeFile = editor.getGrammar().name == 'JSON'

  if wholeFile
    text = editor.getText()
    editor.setText(formatter(text))
  else
    text = editor.replaceSelectedText({}, formatter)

formatter = (text) ->
  editorSettings = atom.config.getSettings().editor
  if editorSettings.softTabs?
    space = Array(editorSettings.tabLength + 1).join(" ")
  else
    space = "\t"

  try
    parsed = JSON.parse(text)
    JSON.stringify(parsed, null, space)
  catch error
    text

module.exports =
  activate: ->
    atom.workspaceView.command 'prettify-json:prettify', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      prettify(editor)
