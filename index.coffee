require('coffee-script/register')

PLUGIN_NAME = 'gulp-iife'

fs      = require 'fs'
_       = require 'lodash'
through = require 'through2'

module.exports = (options) ->
  templates = _.reduce ['coffee'], (memo, type) ->
    memo[type] = _.template fs.readFileSync("#{__dirname}/templates/bundle-#{type}.ejs", encoding: 'utf8')
    memo
  , {}

  wrapInSingleQuotes = (str) ->
    "'" + str.replace("'", "\\'") + "'"

  through.obj (file, enc, next) ->
    if file.isNull()
      @push(file)

    if file.isBuffer()

      filePath = file.path
      if _.isFunction(options.pathModifier)
        filePath = options.pathModifier(file.path)

      contents = file.contents.toString('utf8').replace(/\r?\n/g, '\n  ')

      file.contents = new Buffer templates[options.type](_.extend({
        dependencies: null, namespace: null, wrapInSingleQuotes
      }, options, {contents}))

      @push(file)

    next()