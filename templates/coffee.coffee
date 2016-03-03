_ = require 'lodash'

singleQuote     = (str) -> "'" + str.replace("'", "\\'") + "'"
requireCommonJS = (dep) -> "require(" + singleQuote(dep) + ")"
requireBrowser  = (dep) -> "root.#{dep}"
requireAMD      = (dep) -> singleQuote(dep)

reorderDependencies = (options) ->
  if options.dependencies?
    atBeginning = []
    atEnd       = []

    for dependency in options.dependencies
      if dependency.global?
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
      dep.argument ?= dep.global if dep.global?
      dep

  reorderDependencies(options)

  depsRequire = _.filter(_.pluck(options.dependencies, 'require'))

  argsRequire =
    for dep in options.dependencies when dep.argument? and not dep.native
      dep.argument

  depsNative =
    for dep in options.dependencies when dep.native
      dep.global

  argsNative =
    for dep in options.dependencies when dep.argument? and dep.native
      dep.argument

  depsBrowser = _.filter(_.pluck(options.dependencies, 'global'))

  a =
    for dep in options.dependencies when dep.global? and not dep.native
      dep.global

  s "((factory) ->"
  s ""
  s "  # Browser and WebWorker"
  s "  root = if typeof self is 'object' and self?.self is self"
  s "    self"
  s ""
  s "  # Server"
  s "  else if typeof global is 'object' and global?.global is global"
  s "    global"
  s ""
  s "  # AMD"
  s "  if typeof define is 'function' and define.amd"

  if depsRequire.length > 0
    s "    define [#{depsRequire.concat('exports').map(requireAMD).join(', ')}], (#{argsRequire.join(', ')}) ->"
    s (if options.global?
      "      root.#{options.global} = "
    else "      ") + "factory(#{['root'].concat(depsNative).concat(argsRequire).join(', ')})"

  else
    __module__ = if options.global?
      "root.#{options.global}"
    else "__module__"
    s "    #{__module__} = factory(#{['root'].concat(depsNative).join(', ')})"
    s "    define -> #{__module__}"

  s ""
  s "  # CommonJS"
  s "  else if typeof module is 'object' and module isnt null and"
  s "          module.exports? and typeof module.exports is 'object'"

  s (if options.global?
    "    module.exports = "
  else "    ") + "factory(#{['root'].concat(depsNative).concat(depsRequire.map(requireCommonJS)).join(', ')})"

  s ""
  s "  # Browser and the rest"
  s "  else"

  s (if options.global?
    "    root.#{options.global} = "
  else "    ") + "factory(#{['root'].concat(depsNative).concat(a.map(requireBrowser)).join(', ')})"

  s ""
  s "  # No return value"
  s "  return"
  s ""
  s ")((#{['__root__'].concat(argsNative).concat(argsRequire).join(', ')}) ->"

  s options.indent + options.contents.trim()
  unless options.global?
    s options.indent + "" unless /\r?\n\s*$/.test(options.contents)
    s options.indent + "# No global variable export"
    s options.indent + "return"
  s ")"

  buff.join('\n').trim()
