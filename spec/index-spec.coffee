{WorkspaceView} = require 'atom'

describe "prettify json", ->
  [editor, editorView] = []

  prettify = (callback) ->
    editorView.trigger "prettify-json:prettify"
    runs(callback)

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('prettify-json')
    waitsForPromise -> atom.packages.activatePackage('language-json')

    atom.workspaceView = new WorkspaceView
    atom.workspaceView.openSync()

    editorView = atom.workspaceView.getActiveView()
    editor = editorView.getEditor()

  describe "when no text is selected", ->
    it "doesn't change anything", ->
      editor.setText """
        Start
        { "a": "b", "c": "d" }
        End
      """

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

  describe "JSON file", ->
    beforeEach ->
      editor.setGrammar(atom.syntax.selectGrammar('test.json'))

    describe "with invalid JSON", ->
      it "doesn't change anything", ->
        editor.setText """
          {]
        """

        prettify ->
          expect(editor.getText()).toBe """
            {]
          """

    describe "with valid JSON", ->
      it "formats the whole file correctly", ->
        editor.setText """
          { "a": "b", "c": "d" }
        """

        prettify ->
          expect(editor.getText()).toBe """
            {
              "a": "b",
              "c": "d"
            }
          """
