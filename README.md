# Pretty JSON

[![apm package][apm-ver-link]][releases]
[![travis-ci][travis-ci-badge]][travis-ci]
[![david][david-badge]][david]
[![download][dl-badge]][apm-pkg-link]
[![mit][mit-badge]][mit]

[Atom](http://atom.io/) package for automatically formatting JSON documents.

![img_usage][img_usage]

# Keyboard Command Shortcuts

This package does not by default provide any keyboard command shortcuts. There's no way to know what
keyboard shortcuts are even available on *your* machine. For example, on my machine I could map the
`prettify` command to `shift-cmd-j`. However if *you* have the popular `atom-script` package
installed on your machine, then there would be a conflict because that package also wants to use
that same keyboard shortcut. However, all is not lost!

Atom itself already provides you with everything you need to
[create your own custom keymaps][keymaps]. For example, the following `keymap.cson` would add a
shortcut for the Prettify command:

```cson
'atom-text-editor':
  'shift-cmd-j': 'pretty-json:prettify'
```

## List of Commands Provided by Pretty JSON

Map any of the following commands to your own keyboard shortcuts as described above.

- `pretty-json:prettify`
- `pretty-json:minify`
- `pretty-json:sort-and-prettify`
- `pretty-json:jsonify-literal-and-prettify`
- `pretty-json:jsonify-literal-and-sort-and-prettify`

# General Usage

Select the text to format and then execute the Pretty JSON `prettify` command. For JSON files,
format the entire file automatically without need to first select the text. Minify and sorting
commands are available too.

This plugin will post a notification to Atom if there is a parse error in the JSON. Disable warnings
in this plugin's settings panel if you do not desire this feature.

# JSON Linter

To proactively avoid JSON errors, consider using a linter for JSON, such as the delightful
[linter-jsonlint](https://atom.io/packages/linter-jsonlint).

---

[MIT][mit] © [lexicalunit][lexicalunit], [federomero][federomero] et [al][contributors]

[mit]:              http://opensource.org/licenses/MIT
[lexicalunit]:      http://github.com/lexicalunit
[federomero]:       http://github.com/federomero
[contributors]:     https://github.com/federomero/pretty-json/graphs/contributors
[releases]:         https://github.com/federomero/pretty-json/releases
[mit-badge]:        https://img.shields.io/apm/l/pretty-json.svg
[apm-pkg-link]:     https://atom.io/packages/pretty-json
[apm-ver-link]:     https://img.shields.io/apm/v/pretty-json.svg
[dl-badge]:         http://img.shields.io/apm/dm/pretty-json.svg
[travis-ci-badge]:  https://travis-ci.org/federomero/pretty-json.svg?branch=master
[travis-ci]:        https://travis-ci.org/federomero/pretty-json
[david-badge]:      https://david-dm.org/federomero/pretty-json.svg
[david]:            https://david-dm.org/federomero/pretty-json
[keymaps]:          http://flight-manual.atom.io/using-atom/sections/basic-customization/#customizing-keybindings

[img_usage]:        http://i.imgur.com/Nd4GvtP.gif
