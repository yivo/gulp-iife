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
      if dependency.global
        atBeginning.push(dependency)
      else
        atEnd.push(dependency)

    options.dependencies = atBeginning.concat(atEnd)

module.exports = (options) ->
  buff = []
  s    = (str) -> buff.push(str)

  options.dependencies ||= []
  options.dependencies =
    for dep in options.dependencies
      if dep.global
        dep.argument ||= dep.global
      dep

  reorderDependencies(options)

  deps    = _.filter(_.pluck(options.dependencies, 'require'))
  args    = _.filter(_.pluck(options.dependencies, 'argument'))
  globals = _.filter(_.pluck(options.dependencies, 'global'))

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
    s "    #{__module__} = factory(root)"
    s "    define -> #{__module__}"

  s "  else if typeof module is 'object' && typeof module.exports is 'object'"

  s (if options.global
    "    module.exports = "
  else "    ") + "factory(#{['root'].concat(deps.map(commonJsRequire)).join(', ')})"
  s "  else"

  s (if options.global
    "    root.#{options.global} = "
  else "    ") + "factory(#{['root'].concat(globals.map(browserRequire)).join(', ')})"
  
  s "  return"
  s ")(this, (#{['__root__'].concat(args).join(', ')}) ->"

  s options.indent + options.contents
  unless options.global
    s options.indent + 'return'
  s ")"

  buff.join('\n')
