require('coffee-script/register')

PLUGIN_NAME = 'gulp-iife'

fs      = require 'fs'
_       = require 'lodash'
through = require 'through2'

module.exports = (options) ->
  types = ['coffee']

  templates = _.reduce types, (memo, type) ->
    memo[type] = _.template fs.readFileSync("#{__dirname}/templates/bundle-#{type}.ejs", encoding: 'utf8')
    memo
  , {}

  wrapInSingleQuotes = (str) ->
    "'" + str.replace("'", "\\'") + "'"

  typeToIndent = coffee: '  ', js: '    '

  through.obj (file, enc, next) ->
    if file.isNull()
      @push(file)

    else if file.isBuffer()

      filePath = file.path
      if _.isFunction(options.pathModifier)
        filePath = options.pathModifier(file.path)

      options = _.extend {}, {
        dependencies: null
        namespace: null,
        indent: typeToIndent[options.type]
        wrapInSingleQuotes
      }, options

      options.contents = file.contents.toString('utf8').replace(/\r?\n/g, "\n#{options.indent}")

      file.contents = new Buffer templates[options.type](options)

      @push(file)

    next()