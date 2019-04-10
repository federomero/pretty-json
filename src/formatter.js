/** @babel */

const formatter = {
  space (scope) {
    const softTabs = atom.config.get('editor.softTabs', { scope })
    const tabLength = Number([atom.config.get('editor.tabLength', { scope })])
    if (softTabs) {
      return Array(tabLength + 1).join(' ')
    } else {
      return '\t'
    }
  },

  stringify (obj, options) {
    const scope = ((options != null ? options.scope : undefined) != null) ? options.scope : null
    const sorted = ((options != null ? options.sorted : undefined) != null) ? options.sorted : false

    // lazy load requirements
    const JSONbig = require('json-bigint')
    const stringify = require('json-stable-stringify')
    require('bignumber.js')

    const space = formatter.space(scope)
    if (sorted) {
      return stringify(obj, {
        space,
        replacer (key, value) {
          try {
            if (value.constructor.name === 'BigNumber') {
              return JSONbig.stringify(value)
            }
          } catch (error) {
            // ignore
          }
          return value
        }
      }
      )
    } else {
      return JSONbig.stringify(obj, null, space)
    }
  },

  parseAndValidate (text) {
    const JSONbig = require('json-bigint') // lazy load requirements
    try {
      return JSONbig.parse(text)
    } catch (error) {
      if (atom.config.get('pretty-json.notifyOnParseError')) {
        atom.notifications.addWarning(
          `JSON Pretty: ${error.name}: ${error.message} at character ${error.at} near "${error.text}"`
        )
      }
      throw error
    }
  },

  pretty (text, options) {
    let parsed
    try {
      parsed = formatter.parseAndValidate(text)
    } catch (error) {
      return text
    }
    return formatter.stringify(parsed, options)
  },

  minify (text) {
    try {
      formatter.parseAndValidate(text)
    } catch (error) {
      return text
    }
    const uglify = require('jsonminify') // lazy load requirements
    return uglify(text)
  },

  jsonify  (text, options) {
    const vm = require('vm') // lazy load requirements
    try {
      vm.runInThisContext(`newObject = ${text}`)
    } catch (error) {
      if (atom.config.get('pretty-json.notifyOnParseError')) {
        atom.notifications.addWarning(`JSON Pretty: eval issue: ${error}`)
      }
      return text
    }
    return formatter.stringify(newObject, options) // eslint-disable-line no-undef
  }
}

export default formatter
