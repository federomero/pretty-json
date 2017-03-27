describe 'Pretty JSON', ->
  [PrettyJSON] = []

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('language-json')
    waitsForPromise -> atom.packages.activatePackage('language-gfm')
    waitsForPromise ->
      atom.packages.activatePackage('pretty-json').then (pack) ->
        PrettyJSON = pack.mainModule

  describe 'when prettifying large data file', ->
    it 'does not crash', ->
      waitsForPromise ->
        atom.workspace.open('large.json')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: false

  describe 'when prettifying large integers', ->
    it 'does not truncate integers', ->
      waitsForPromise ->
        atom.workspace.open('bigint.json')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: false
            expect(editor.getText()).toBe """
            {
              "bigint": 6926665213734576388,
              "float": 1.23456e-10
            }
            """

  describe 'when no text is selected', ->
    it 'does not change anything', ->
      waitsForPromise ->
        atom.workspace.open('valid.md')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: false
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
            editor.setSelectedBufferRange([[1, 0], [1, 22]])
            PrettyJSON.prettify editor,
              sorted: false
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
            editor.setSelectedBufferRange([[1, 0], [1, 2]])
            PrettyJSON.prettify editor,
              sorted: false
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
            PrettyJSON.prettify editor,
              sorted: false
            expect(editor.getText()).toBe """
            { "c": "d", "a": "b", }

            """

  describe 'JSON file with valid JSON', ->
    it 'formats the whole file correctly', ->
      waitsForPromise ->
        atom.workspace.open('valid.json')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: false
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
            PrettyJSON.prettify editor,
              sorted: true
            expect(editor.getText()).toBe """
            { "c": "d", "a": "b", }

            """

  describe 'Sort and prettify JSON file with valid JSON', ->
    it 'formats the whole file correctly', ->
      waitsForPromise ->
        atom.workspace.open('valid.json')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: true
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
            PrettyJSON.minify editor
            expect(editor.getText()).toBe """
            { "c": "d", "a": "b", }

            """

  describe 'Minify JSON file with valid JSON', ->
    it 'formats the whole file correctly', ->
      waitsForPromise ->
        atom.workspace.open('valid.json')
          .then (editor) ->
            PrettyJSON.minify editor
            expect(editor.getText()).toBe """
              {"c":"d","a":"b"}
            """

  describe 'Minify selected JSON', ->
    it 'Minifies JSON data', ->
      waitsForPromise ->
        atom.workspace.open('valid.md')
          .then (editor) ->
            editor.setSelectedBufferRange([[1, 0], [1, 22]])
            PrettyJSON.minify editor
            expect(editor.getText()).toBe """
              Start
              {"c":"d","a":"b" }
              End

            """

  describe 'JSON file with valid JavaScript Object Literal', ->
    it 'jsonifies file correctly', ->
      waitsForPromise ->
        atom.workspace.open('object.json')
          .then (editor) ->
            PrettyJSON.jsonify editor,
              sorted: false
            expect(editor.getText()).toBe """
              {
                "c": 3,
                "a": 1
              }
            """

  describe 'JSON file with valid JavaScript Object Literal', ->
    it 'jsonifies and sorts file correctly', ->
      waitsForPromise ->
        atom.workspace.open('object.json')
          .then (editor) ->
            PrettyJSON.jsonify editor,
              sorted: true
            expect(editor.getText()).toBe """
              {
                "a": 1,
                "c": 3
              }
            """

  describe 'Sort and prettify JSON file with BigNumbers', ->
    it 'does not destroy formatting of numbers', ->
      waitsForPromise ->
        atom.workspace.open('stats.json')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: true
            expect(editor.getText()).toBe """
              {
                "DV": [
                  {
                    "BC": 100,
                    "Chromosome": "chr22",
                    "PopulationFrequencyEthnicBackground": "20.316622691292874",
                    "PopulationFrequencyGeneral": "29.716117216117215",
                    "RQ": null,
                    "ZW": [
                    ]
                  }
                ]
              }
            """

  describe 'when a valid json text is selected', ->
    it 'formats it correctly, and selects the formatted text', ->
      waitsForPromise ->
        atom.workspace.open('selected.json')
          .then (editor) ->
            editor.setSelectedBufferRange([[0, 0], [0, 32]])
            PrettyJSON.prettify editor,
              sorted: false
            expect(editor.getText()).toBe """
              {
                "key": {
                  "key": {
                    "key": "value"
                  }
                }
              }

            """
            range = editor.getSelectedBufferRange()
            expect(range.start.row).toBe 0
            expect(range.start.column).toBe 0
            expect(range.end.row).toBe 6
            expect(range.end.column).toBe 1

  # Sort plus prettify causes floating point numbers to become strings.
  # See issue #62 for more details.
  xdescribe 'when sorting and prettifying floating point numbers', ->
    it 'does not turn them into strings', ->
      waitsForPromise ->
        atom.workspace.open('floating.json')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: true
            expect(editor.getText()).toBe """
            {
              "floating_point": -0.6579373322603248
            }
            """

  # Prettify can affect JavaScript number representation; ie. 6.0 => 6.
  # See issue #46 for more details.
  xdescribe 'when prettifying whole numbers represented as floating point', ->
    it 'does not turn them into whole numbers', ->
      waitsForPromise ->
        atom.workspace.open('number.json')
          .then (editor) ->
            PrettyJSON.prettify editor,
              sorted: false
            expect(editor.getText()).toBe """
            {
              "int": 6.0
            }
            """
