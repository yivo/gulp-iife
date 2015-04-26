# gulp-iife
This small gulp plugin wraps your code in [IIFE](http://en.wikipedia.org/wiki/Immediately-invoked_function_expression) to distribute on three platforms: AMD, CommonJS and Browser environment.

## Installation
```
npm install yivo/gulp-iife
```

## Usage
```js
var iife = require('gulp-iife');
gulp.task('build', function() {
  gulp.src('index.js')
  	.pipe(iife({global: 'MyModule', dependencies: [
    	{name: 'lodash', as: '_'}
    ], global: 'MyModule'}))

// The result will look like:
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    return define(['lodash'], function(_) {
      return root.MyModule = factory(root, _);
    });
  } else if (typeof module === 'object' && typeof module.exports === 'object') {
    return module.exports = factory(root, require('lodash'));
  } else {
    return root.MyModule = factory(root, root._);
  }
})(this, function(root, _) {
  var MyModule = {};
  // ....
  return MyModule;
});

```
