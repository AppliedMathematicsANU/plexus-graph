###
This module provides some convenience functions for working with
[Mori](https://github.com/swannodette/mori) data structures.
###

_ = require 'mori'


second = (coll) ->
  ### Returns the second element of the given collection. ###
  _.nth(coll, 1)

countAtLeast = (n, coll) ->
  ### Tests if the collection `coll` has at least `n` elements. ###
  _.count(_.take(n, coll)) >= n

isEmpty = (coll) ->
  ### Tests if the given collection contains no elements. ###
  not _.seq(coll)

any = (p, coll) ->
  ###
  Tests if predicate `p` is true for any element of the collection `coll`.
  ###
  _.seq(_.filter(p, coll))?

all = (p, coll) ->
  ###
  Tests if predicate `p` is true for all elements of the collection `coll`.
  ###
  not any(((x) -> not p(x)), coll)

iterateAndTrim = (f, x) ->
  ###
  Returns a lazy sequence of `x`, `f(x)`, `f(f(x))` and so on, which is
  terminated at the first `null` or `undefined`.
  ###
  _.take_while(((x) -> x?), _.iterate(f, x))


module.exports =
  second        : second
  countAtLeast  : countAtLeast
  isEmpty       : isEmpty
  any           : any
  all           : all
  iterateAndTrim: iterateAndTrim
