# gulp-umd-wrap
Wraps JavaScript and CoffeeScript sources in UMD.

## Installation
```
npm i gulp-umd-wrap
```

## Status
Supports JavaScript and CoffeeScript sources.

## Usage
##### module.coffee
```coffee
Module =
  foo: ->
  bar: ->
  baz: ->
```

##### gulpfile.coffee
```coffee
gulp   = require('gulp')
concat = require('gulp-concat')
umd    = require('gulp-umd-wrap')

umdOptions = ->
  # For Browser and Web Worker environments global variable will be set on this: 
  # window for Browser, self for Web Worker.
  # This option is not required.
  global = 'Module'

  # For each dependency require and global must be specified:
  #   require: module name in AMD/CommonJS compatible environments;
  #   global: module name in Browser and Web Worker environments.
  # This option is not required.
  dependencies = [
    { require: 'lodash', global: '_' }
    { require: 'jquery', global: '$'}
  ]
  
  # Header for UMD expression.
  # This option is not required.
  header = """
    ###
    # module.coffee 1.0.0 | github.com/module-author/module | LICENSE
    ###
  """

  {global, dependencies, header}

gulp.task 'build', ->
  gulp.src('module.coffee')
    .pipe umd(umdOptions())
    .pipe concat('module-umd.coffee')
    .pipe gulp.dest('.')
```

##### module-umd.coffee
```coffee
###
# module.coffee 1.0.0 | github.com/module-author/module | LICENSE
###
((factory) ->

  __root__ = 
    # The root object for Browser or Web Worker
    if typeof self is 'object' and self isnt null and self.self is self
      self

    # The root object for Server-side JavaScript Runtime
    else if typeof global is 'object' and global isnt null and global.global is global
      global

    else
      Function('return this')()

  # Asynchronous Module Definition (AMD)
  if typeof define is 'function' and typeof define.amd is 'object' and define.amd isnt null
    define ['lodash', 'jquery'], (_, $) ->
      __root__.Module = factory(__root__, _, $)

  # Server-side JavaScript Runtime compatible with CommonJS Module Spec
  else if typeof module is 'object' and module isnt null and typeof module.exports is 'object' and module.exports isnt null
    module.exports = factory(__root__, require('lodash'), require('jquery'))

  # Browser, Web Worker and the rest
  else
    __root__.Module = factory(__root__, _, $)

  # No return value
  return

)((__root__, _, $) ->
  Module =
    foo: ->
    bar: ->
    baz: ->
)
```
