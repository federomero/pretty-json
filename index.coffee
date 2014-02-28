prettify = (editor) ->
  text = editor.getSelectedText()

  editorSettings = atom.config.getSettings().editor
  if editorSettings.softTabs?
    space = Array(editorSettings.tabLength + 1).join(" ")
  else
    space = "\t"

  try
    parsed = JSON.parse(text)
    result = JSON.stringify(parsed, null, space)
  catch error
    result = text

  editor.setTextInBufferRange(editor.getSelectedBufferRange(), result);

module.exports =
  activate: ->
    atom.workspaceView.command 'prettify-json:prettify', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      prettify(editor)
