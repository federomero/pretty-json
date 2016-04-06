describe 'Pretty JSON', ->
  [PrettyJSON] = []

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('language-json')
    waitsForPromise ->
      atom.packages.activatePackage('pretty-json').then (pack) ->
        PrettyJSON = pack.mainModule

  describe 'when no text is selected', ->
    it 'does not change anything', ->
      waitsForPromise ->
        atom.workspace.open('valid.md')
          .then (editor) ->
            PrettyJSON.prettify editor, false
            expect(editor.getText()).toBe """
              Start
              { "c": "d", "a": "b" }
              End

            """

  describe 'when a valid json text is selected', ->
    it 'formats it correctly', ->
      waitsForPromise ->
        atom.workspace.open('valid.md')
          .then (editor) ->
            editor.setSelectedBufferRange([[1,0], [1, 22]])
            PrettyJSON.prettify editor, false
            expect(editor.getText()).toBe """
              Start
              {
                "c": "d",
                "a": "b"
              }
              End

            """

  describe 'when an invalid json text is selected', ->
    it 'does not change anything', ->
      waitsForPromise ->
        atom.workspace.open('invalid.md')
          .then (editor) ->
            editor.setSelectedBufferRange([[1,0], [1, 2]])
            PrettyJSON.prettify editor, false
            expect(editor.getText()).toBe """
            Start
            {]
            End

            """

  describe 'JSON file with invalid JSON', ->
    it 'does not change anything', ->
      waitsForPromise ->
        atom.workspace.open('invalid.json')
          .then (editor) ->
            PrettyJSON.prettify editor, false
            expect(editor.getText()).toBe """
            { "c": "d", "a": "b", }

            """

  describe 'JSON file with valid JSON', ->
    it 'formats the whole file correctly', ->
      waitsForPromise ->
        atom.workspace.open('valid.json')
          .then (editor) ->
            PrettyJSON.prettify editor, false
            expect(editor.getText()).toBe """
              {
                "c": "d",
                "a": "b"
              }
            """

  describe 'Sort and prettify JSON file with invalid JSON', ->
    it 'does not change anything', ->
      waitsForPromise ->
        atom.workspace.open('invalid.json')
          .then (editor) ->
            PrettyJSON.prettify editor, true
            expect(editor.getText()).toBe """
            { "c": "d", "a": "b", }

            """

  describe 'Sort and prettify JSON file with valid JSON', ->
    it 'formats the whole file correctly', ->
      waitsForPromise ->
        atom.workspace.open('valid.json')
          .then (editor) ->
            PrettyJSON.prettify editor, true
            expect(editor.getText()).toBe """
              {
                "a": "b",
                "c": "d"
              }
            """

  describe 'Minify JSON file with invalid JSON', ->
    it 'does not change anything', ->
      waitsForPromise ->
        atom.workspace.open('invalid.json')
          .then (editor) ->
            PrettyJSON.minify editor, false
            expect(editor.getText()).toBe """
            { "c": "d", "a": "b", }

            """

  describe 'Minify JSON file with valid JSON', ->
    it 'formats the whole file correctly', ->
      waitsForPromise ->
        atom.workspace.open('valid.json')
          .then (editor) ->
            PrettyJSON.minify editor, false
            expect(editor.getText()).toBe """
              {"c":"d","a":"b"}
            """

  describe 'Minify selected JSON', ->
    it 'Minifies JSON data', ->
      waitsForPromise ->
        atom.workspace.open('valid.md')
          .then (editor) ->
            editor.setSelectedBufferRange([[1,0], [1, 22]])
            PrettyJSON.minify editor, false
            expect(editor.getText()).toBe """
              Start
              {"c":"d","a":"b" }
              End

            """
