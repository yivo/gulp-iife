coffee = require('coffee-script')

module.exports = (options) ->
  options.contents = "```#{options.contents}```"
  coffee.compile(require('./coffee.coffee')(options), bare: true)
