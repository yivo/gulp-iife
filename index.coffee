PLUGIN_NAME = 'gulp-iife'

fs      = require 'fs'
_       = require 'lodash'
through = require 'through2'

typeToTemplate =
  coffee: require('./templates/coffee.coffee')
  js: require('./templates/js.coffee')

typeToIndent =
  coffee: '  '
  js: '    '

module.exports = (config = {}) ->
  through.obj (file, enc, next) ->
    if file.isNull()
      @push(file)

    else if file.isBuffer()

      filePath = if _.isFunction(config.pathModifier)
        config.pathModifier(file.path)
      else file.path

      options = _.extend({}, config)

      options.type ||= filePath.match(/\.([^\.]+)$/)?[1]
      options.indent ||= typeToIndent[options.type]
      options.contents = file.contents.toString('utf8').replace(/\r?\n/g, "\n#{options.indent}")

      file.contents = new Buffer typeToTemplate[options.type](options)

      @push(file)

    next()