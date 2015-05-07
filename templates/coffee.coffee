_ = require 'lodash'

singleQuote = (str) ->
  "'" + str.replace("'", "\\'") + "'"

commonJsRequire = (dep) ->
  "require(" + singleQuote(dep) + ")"

browserRequire = (dep) ->
  "root.#{dep}"

amdRequire = (dep) ->
  singleQuote(dep)

reorderDependencies = (options) ->
  if options.dependencies
    atBeginning = []
    atEnd = []

    for dependency in options.dependencies
      if dependency.as
        atBeginning.push(dependency)
      else
        atEnd.push(dependency)

    options.dependencies = atBeginning.concat(atEnd)

module.exports = (options) ->
  buff = []
  s = (str) -> buff.push str

  reorderDependencies(options)

  deps = _.filter(_.pluck(options.dependencies, 'name'))
  args = _.filter(_.pluck(options.dependencies, 'as'))

  s "((root, factory) ->"
  s "  if typeof define is 'function' and define.amd"

  if deps.length
    s "    define [#{deps.map(amdRequire).join(', ')}], (#{args.join(', ')}) ->"
    s (if options.global
      "      root.#{options.global} = "
    else "      ") + "factory(#{['root'].concat(args).join(', ')})"

  else
    __module__ = if options.global
      "root.#{options.global}"
    else "__module__"
    s "   #{__module__} = factory(root)"
    s "   define -> #{__module__}"

  s "  else if typeof module is 'object' && typeof module.exports is 'object'"

  s (if options.global
    "    module.exports = "
  else "    ") + "factory(#{['root'].concat(deps.map(commonJsRequire)).join(', ')})"
  s "  else"

  s (if options.global
    "    root.#{options.global} = "
  else "    ") + "factory(#{['root'].concat(args.map(browserRequire)).join(', ')})"
  
  s "  return"
  s ")(this, (#{['root'].concat(args).join(', ')}) ->"

  s options.indent + options.contents
  unless options.global
    s options.indent + 'return'
  s ")"

  buff.join('\n')
