fs      = require('fs')
_       = require('lodash')
through = require('through2')

TYPE_TO_TEMPLATE =
  coffee: require('./templates/coffee.coffee')
  js:     require('./templates/js.coffee')

TYPE_TO_INDENT =
  coffee: '  '
  js:     '    '

module.exports = (config = {}) ->
  through.obj (file, enc, next) ->
    if file.isBuffer()
      filepath = if _.isFunction(config.pathModifier)
        config.pathModifier(file.path)
      else file.path

      options = _.extend({}, config)

      options.type   ||= filepath.match(/\.([^\.]+)$/)?[1]
      options.indent ||= TYPE_TO_INDENT[options.type]
      options.contents = file.contents.toString('UTF-8').replace(/\r?\n/g, "\n#{options.indent}")
      file.contents    = new Buffer(TYPE_TO_TEMPLATE[options.type](options))
    
    @push(file)
    next()
