{WorkspaceView} = require 'atom'

describe "prettify json", ->
  [activationPromise, editor, editorView] = []

  prettify = (callback) ->
    editorView.trigger "prettify-json:prettify"
    waitsForPromise -> activationPromise
    runs(callback)

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.openSync()

    editorView = atom.workspaceView.getActiveView()
    editor = editorView.getEditor()

    activationPromise = atom.packages.activatePackage('prettify-json')

  describe "when no text is selected", ->
    it "doesn't change anything", ->
      editor.setText """
        Start
        { "a": "b", "c": "d" }
        End
      """
      editor.setCursorBufferPosition([0, 0])

      prettify ->
        expect(editor.getText()).toBe """
          Start
          { "a": "b", "c": "d" }
          End
        """


  describe "when a valid json text is selected", ->
    it "formats it correctly", ->
      editor.setText """
        Start
        { "a": "b", "c": "d" }
        End
      """
      editor.setSelectedBufferRange([[1,0], [1, 22]])

      prettify ->
        expect(editor.getText()).toBe """
          Start
          {
            "a": "b",
            "c": "d"
          }
          End
        """

  describe "when an invalid json text is selected", ->
    it "doesn't change anything", ->
      editor.setText """
        Start
        {]
        End
      """
      editor.setSelectedBufferRange([[1,0], [1, 2]])

      prettify ->
        expect(editor.getText()).toBe """
          Start
          {]
          End
        """
