PLACEHOLDER = '__CONTENTS__'
coffee = require('coffee-script')

module.exports = (options) ->
  contents = options.contents
  options.contents = PLACEHOLDER
  code = coffee.compile(require('./coffee.coffee')(options), bare: yes)
  code.replace("#{PLACEHOLDER};", contents)