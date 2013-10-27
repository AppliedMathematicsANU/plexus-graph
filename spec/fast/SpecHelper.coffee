_ = require 'mori'

exports.expectSet = (given, expected) ->
  expect(_.clj_to_js(given).sort()).toEqual(expected.sort())
