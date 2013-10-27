claire = require 'claire'
graph = require '../../src/PersistentGraph'


choose = (a, b) -> Math.random()*(b - a) + a

chooseInt = (a, b) -> Math.floor(choose(a, b))


generator = (name, obj) ->
  gen = {}
  for key, val of claire.Generator then gen[key] = val
  gen.toString = -> "<#{name}>"
  for key, val of obj then gen[key] = val
  gen


exports.$ = claire.data

exports.forAll = claire.forAll

exports.expectProperty = (prop) -> expect(prop.asTest()).not.toThrow()

exports.Graph = (p, dagsOnly = false) ->
  generator 'Graph',
    next: (n) ->
      size = n or @size
      nv = Math.sqrt(size * (1 + dagsOnly) / p)
      verts = [1..chooseInt(0, nv)]
      edges = []
      for v in verts
        for w in verts
          if (w > v or (not dagsOnly and w < v)) and Math.random() <= p
            edges.push([v, w])
      claire.makeValue(graph(edges, verts), this)


exports.DAG = (p) -> claire.label('DAG', Graph(p, true))
