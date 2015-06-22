{WorkspaceView} = require 'atom'

describe "pretty json", ->
  [editor, editorView] = []

  prettify = (callback) ->
    editorView.trigger "pretty-json:prettify"
    runs(callback)

  minify = (callback) ->
    editorView.trigger "pretty-json:minify"
    runs(callback)

  sortedPrettify = (callback) ->
    editorView.trigger "pretty-json:sort-and-prettify"
    runs(callback)

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('pretty-json')
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

    describe "Sort and prettify", ->
      beforeEach ->
        editor.setGrammar(atom.syntax.selectGrammar('test.json'))

      describe "with invalid JSON", ->
        it "doesn't change anything", ->
          editor.setText """
            {]
          """

          sortedPrettify ->
            expect(editor.getText()).toBe """
              {]
            """

      describe "with valid JSON", ->
        it "formats the whole file correctly", ->
          editor.setText """
            { "c": "d", "a": "b" }
          """

          sortedPrettify ->
            expect(editor.getText()).toBe """
              {
                "a": "b",
                "c": "d"
              }
            """

  describe "Minify JSON file", ->
    beforeEach ->
      editor.setGrammar(atom.syntax.selectGrammar('test.json'))

    it "Returns same string from invalid JSON", ->
      editor.setText """
        {
          [
        }
      """

      minify ->
        expect(editor.getText()).toBe """
          {
            [
          }
        """

    it "Minifies valid JSON", ->
      editor.setText """
        {
          "a": "b",
          "c": "d",
          "num": 123
        }
      """

      minify ->
        expect(editor.getText()).toBe """
          {"a":"b","c":"d","num":123}
        """

  describe "Minify selected JSON", ->
    it "Minifies JSON data", ->
      editor.setText """
        Start
        {
          "a": "b",
          "c": "d",
          "num": 123
        }
        End
      """
      editor.setSelectedBufferRange([[1,0], [5, 1]])

      minify ->
        expect(editor.getText()).toBe """
          Start
          {"a":"b","c":"d","num":123}
          End
        """
