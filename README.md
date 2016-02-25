# gulp-iife
This small gulp plugin wraps your code in [IIFE](http://en.wikipedia.org/wiki/Immediately-invoked_function_expression) to distribute on three platforms: AMD, CommonJS and Browser environment.

## Installation
```
npm i gulp-iife
```

## Status
Currently it is well supported scripts written in CoffeeScript. JavaScript is supported too but it is buggy.

## Usage
Assume you have some module definition:
```coffee
Module =
  foo: ->
  bar: ->
  baz: ->
```
You would like to distribute this module on browser, AMD, and CommonJS environment. To do this you need to wrap your code with IIFE.

```coffee
gulp = require('gulp')
iife = require('gulp-iife')

# Define dependencies for your module. Here we will define you dependencies: lodash and jquery.
dependencies = [
    // in AMD/CommonJS:          require('lodash')
    // in browser:               window._
    // argument name in factory: _
    { require: 'lodash',  global: '_' },

    // in AMD/CommonJS:          require('jquery')
    // in browser:               window.$
    // argument name in factory: $
    { require: 'jquery', global: '$'}
];

# Here we specify how our module will be named in browser environment.
# In other words here we specify property name which users will use to access module in browsers: window.Module
global = 'Module';

gulp.task 'build', ->
  gulp.src('source/module.coffee')
    .pipe iife {global, dependencies}
    .pipe gulp.dest('build')
```

After running gulp we will have this code:
```coffee
((factory) ->

  # Browser and WebWorker
  root = if typeof self is 'object' and self?.self is self
    self

  # Server
  else if typeof global is 'object' and global?.global is global
    global

  # AMD
  if typeof define is 'function' and define.amd
    define ['lodash', 'jquery', 'exports'], (_, $) ->
      root.Module = factory(root, _, $)

  # CommonJS
  else if typeof module is 'object' and module isnt null and
          module.exports? and typeof module.exports is 'object'
    module.exports = factory(root, require('lodash'), require('jquery'))

  # Browser and the rest
  else
    root.Module = factory(root, root._, root.$)

  # No return value
  return

)((__root__, _, $) ->
  Module =
    foo: ->
    bar: ->
    baz: ->
)
```
