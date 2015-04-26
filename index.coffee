PLUGIN_NAME = 'gulp-iife'

fs      = require 'fs'
_       = require 'lodash'
through = require 'through2'

typeToTemplate =
  coffee: require('./templates/coffee.coffee')

typeToIndent =
  coffee: '  '
  js: '    '

module.exports = (options = {}) ->
  through.obj (file, enc, next) ->
    if file.isNull()
      @push(file)

    else if file.isBuffer()

      filePath = if _.isFunction(options.pathModifier)
        options.pathModifier(file.path)
      else file.path

      options.type ||= filePath.match(/\.([^\.]+)$/)?[1]
      options.indent ||= typeToIndent[options.type]
      options.contents = file.contents.toString('utf8').replace(/\r?\n/g, "\n#{options.indent}")

      file.contents = new Buffer typeToTemplate[options.type](options)

      @push(file)

    next()