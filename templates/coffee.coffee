_ = require 'lodash'

singleQuote     = (str) -> "'" + str.replace("'", "\\'") + "'"
requireCommonJS = (dep) -> "require(" + singleQuote(dep) + ")"
requireBrowser  = (dep) -> "root.#{dep}"
requireAMD      = (dep) -> singleQuote(dep)

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

  if deps.length
    s "    define [#{deps.concat('exports').map(requireAMD).join(', ')}], (#{args.join(', ')}) ->"
    s (if options.global
      "      root.#{options.global} = "
    else "      ") + "factory(#{['root'].concat(args).join(', ')})"

  else
    __module__ = if options.global
      "root.#{options.global}"
    else "__module__"
    s "    #{__module__} = factory(root)"
    s "    define -> #{__module__}"

  s ""
  s "  # CommonJS"
  s "  else if typeof module is 'object' and module isnt null and"
  s "          module.exports? and typeof module.exports is 'object'"

  s (if options.global
    "    module.exports = "
  else "    ") + "factory(#{['root'].concat(deps.map(requireCommonJS)).join(', ')})"

  s ""
  s "  # Browser and the rest"
  s "  else"

  s (if options.global
    "    root.#{options.global} = "
  else "    ") + "factory(#{['root'].concat(globals.map(requireBrowser)).join(', ')})"

  s ""
  s "  # No return value"
  s "  return"
  s ""
  s ")((#{['__root__'].concat(args).join(', ')}) ->"

  s options.indent + options.contents
  unless options.global
    s options.indent + "" unless /\r?\n\s*$/.test(options.contents)
    s options.indent + "# No global variable export"
    s options.indent + "return"
  s ")"

  buff.join('\n')
