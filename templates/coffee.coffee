_ = require 'lodash'

singleQuote     = (str) -> "'" + str.replace("'", "\\'") + "'"
requireCommonJS = (dep) -> "require(" + singleQuote(dep) + ")"
requireBrowser  = (dep) -> "__root__.#{dep}"
requireAMD      = (dep) -> singleQuote(dep)

reorderDependencies = (options) ->
  options.dependencies = do ->
    atBeginning = []
    atEnd       = []
    for dependency in options.dependencies
      if dependency.global?
        atBeginning.push(dependency)
      else
        atEnd.push(dependency)
    atBeginning.concat(atEnd)

module.exports = (options = {}) ->
  buff = []
  s    = (str) -> buff.push(str)
  
  for dep in (options.dependencies ?= []) when dep.global?
    dep.argument ?= dep.global

  reorderDependencies(options)

  depsRequire = _.filter(_.map(options.dependencies, 'require'))
  argsRequire = (dep.argument for dep in options.dependencies when dep.argument? and not dep.native)
  depsNative  = (dep.global   for dep in options.dependencies when dep.native)
  argsNative  = (dep.argument for dep in options.dependencies when dep.argument? and dep.native)
  depsBrowser = (dep.global   for dep in options.dependencies when dep.global? and not dep.native)

  s options.license if options.license
  s "((factory) ->"
  s ""
  s "  __root__ = "
  s "    # The root object for Browser or Web Worker"
  s "    if typeof self is 'object' and self isnt null and self.self is self"
  s "      self"
  s ""
  s "    # The root object for server-side JavaScript runtime"
  s "    else if typeof global is 'object' and global isnt null and global.global is global"
  s "      global"
  s ""
  s "    else"
  s "      this"
  s ""
  s "  # Asynchronous Module Definition (AMD)"
  s "  if typeof define is 'function' and typeof define.amd is 'object' and define.amd isnt null"

  if depsRequire.length > 0
    s "    define [#{depsRequire.map(requireAMD).join(', ')}], (#{argsRequire.join(', ')}) ->"
    s (if options.global?
      "      __root__.#{options.global} = "
    else "      ") + "factory(#{['__root__'].concat(depsNative).concat(argsRequire).join(', ')})"

  else
    __module__ = if options.global? then "__root__.#{options.global}" else "__module__"
    s "    #{__module__} = factory(#{['__root__'].concat(depsNative).join(', ')})"
    s "    define -> #{__module__}"

  s ""
  s "  # Server-side JavaScript runtime compatible with CommonJS Module Spec"
  s "  else if typeof module is 'object' and module isnt null and typeof module.exports is 'object' and module.exports isnt null"

  s (if options.global?
    "    module.exports = "
  else "    ") + "factory(#{['__root__'].concat(depsNative).concat(depsRequire.map(requireCommonJS)).join(', ')})"

  s ""
  s "  # Browser, Web Worker and the rest"
  s "  else"

  s (if options.global?
    "    __root__.#{options.global} = "
  else "    ") + "factory(#{['__root__'].concat(depsNative).concat(depsBrowser.map(requireBrowser)).join(', ')})"

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
