# gulp-iife
This small gulp plugin wraps your code in [IIFE](http://en.wikipedia.org/wiki/Immediately-invoked_function_expression) to distribute on three platforms: AMD, CommonJS and Browser environment.

## Installation
```
npm install yivo/gulp-iife
```

## Usage
```js
var gulp = require('gulp');
var iife = require('gulp-iife');

// This makes your module accessible in browsers: window.MyModule
var global = 'MyModule';

var dependencies = [
    // in AMD/CommonJS: require('lodash')
    // in browser: window._
    // argument name in factory: _
    { require: 'lodash',  global: '_' },

    // in AMD/CommonJS: require('XRegExp')
    // in browser: window.XRegExp
    // argument name in factory: XRegExpExports
    { require: 'XRegExp', global: 'XRegExp', argument: 'XRegExpExports'}
];

gulp.task('build', function() {
    gulp.src('index.js')
        .pipe(iife({
            global: global, dependencies: dependencies
        }))
        .pipe(gulp.dest('build'));
});
```