###

An implementation of simple, directed graphs as a [persistent data
structure](http://en.wikipedia.org/wiki/Persistent_data_structure).

For our purposes, a directed graph consists of a set of vertices and a
collection of ordered vertex pairs, called the edges of the graph. Vertices
can be of any type, including mixed types within the same graph, but must be
immutable.

This implementation is restricted to simple graphs, meaning that no vertex
pair can occur more than once as an edge, and there are no *loops* (edges that
start and end in the same vertex). It is, however, possible to have an edge,
say `[v, w]`, as well as its reverse, `[w, v]`.

Persistence means in essence that instances of this class are immutable and
any methods that create modifications of existing graphs will return new,
independent objects which may share some common data with the originals.


This module exports as a factory function which can be called to create new
directed graphs. The first argument must be an array of directed edges, given
as vertex pairs. The optional second argument must be an array of vertices and
can be used when creating graphs with some isolated vertices.

Usage example:

    makeGraph = require('./PersistentGraph')
    G = makeGraph([[1,2],[1,3],[2,4],[3,4]], [5])
    console.log(G.predecessors(4))
    # -> [2, 3]
    console.log(G.adjacent(5))
    # -> []

###

_ = require 'mori'


class PersistentGraph
  ###

  The Implementation class. This class is not exported. Instead, the
  containing module exports as a factory function which can be called to
  create new instances. In addition, there are instance methods
  `withVertices`, `withEdges`, `withoutVertices` and `withoutEdges` for
  creating modifications of existing graph instances.

  A graph is represented redundantly as a set of vertices and two maps for the
  sets of predecessors and successors of vertices. We store this data in
  persistent data structures borrowed from ClojureScript via the
  [Mori](https://github.com/swannodette/mori) library by David Nolen
  (@swannodette).

  When Mori data structures are used as vertices, their equality is determined
  structurally. In other words, two Mori collections with the same contents
  and order are considered equal even if the representing objects are
  distinct. This is not the case for plain Javascript objects.

  ###

  constructor: (@_verts, @_pred, @_succ) ->
    ###
    This low-level constructor should not be called directly (see above).
    ###

  vertices: ->
    ### The vertices of this graph as an array. ###
    _.into_array(@_verts)

  predecessors: (v) ->
    ### The immediate predecessors of the given vertex as an array. ###
    _.into_array(_.get(@_pred, v))

  successors: (v) ->
    ### The immediate successors of the given vertex as an array. ###
    _.into_array(_.get(@_succ, v))

  isVertex: (v) ->
    ### Tests whether the given object is a vertex of this graph. ###
    _.has_key(@_verts, v)

  isEdge: (v, w) ->
    ### Tests whether the given pair forms a directed edge of this graph. ###
    _.has_key(_.get(@_succ, v), w)

  isSource: (v) ->
    ### Tests whether the given object is a vertex with no predecessors. ###
    @isVertex(v) and _.seq(_.get(@_pred, v)) is null

  isSink: (v) ->
    ### Tests whether the given object is a vertex with no successors. ###
    @isVertex(v) and _.seq(_.get(@_succ, v)) is null

  edges: ->
    ### The directed edges of this graph as an array of pairs. ###
    outgoing = (v) => _.map(_.vector, _.repeat(v), _.get(@_succ, v))
    _.into_array(_.map(_.into_array, _.mapcat(outgoing, @_verts)))

  adjacent: (v) ->
    ### All the vertices adjacent to the given one as an array. ###
    _.into_array(_.union(_.get(@_pred, v), _.get(@_succ, v)))

  equals: (other) ->
    ###
    Tests whether this graph is equal to the given one in the sense that the
    two graphs have the same sets of vertices and directed edges.
    ###
    if not _.equals(this.vertices(), other.vertices())
      false
    else
      for v in this.vertices()
        if not _.equals(this.predecessors(v), other.predecessors(v))
          return false
    true

  toJSON: ->
    ###

    Produces a representation of this graph as an object with properties
    `"vertices"` and `"edges"` suitable for serialisation via JSON.

    When using this function to serialize and later recreate a graph, please
    note that any Mori collections used as vertices will be converted to
    corresponding plain Javascript objects or arrays on output. The functions
    and methods that create graph instances, on the other hand, do not perform
    the opposite conversion.

    ###
    outgoing = (v) => _.map(_.vector, _.repeat(v), _.get(@_succ, v))
    edges = _.mapcat(outgoing, @_verts)

    'vertices': _.clj_to_js(_.sort(@_verts))
    'edges': _.clj_to_js(_.sort(edges))

  withVertices: (vs) ->
    ###
    Creates a modification of this graph with some vertices added. The
    argument must be an array containing the new vertices. Vertices already
    present in the graph are silently ignored.
    ###
    vs = _.set(vs)

    addOne = (m, v) ->  if _.has_key(m, v) then m else _.assoc(m, v, _.set())
    add = (m, vs) -> _.reduce(addOne, m, vs)

    new PersistentGraph(_.union(@_verts, vs), add(@_pred, vs), add(@_succ, vs))

  withoutVertices: (vs) ->
    ###
    Creates a modification of this graph with some vertices, together with all
    their incident edges, removed. The argument must be an array containing
    the vertices to be removes. Vertices not present in the graph are silently
    ignored.
    ###
    vs = _.set(vs)

    purge = (m, vs) ->
      seen = _.partial(_.has_key, vs)
      clean = (m, w) -> _.assoc(m, w, _.set(_.remove(seen, _.get(m, w))))
      keys = _.map(_.first, _.seq(m))
      _.reduce(_.dissoc, _.reduce(clean, m, keys), vs)

    new PersistentGraph(
      _.difference(@_verts, vs),
      purge(@_pred, vs),
      purge(@_succ, vs))

  withEdges: (es) ->
    ###
    Creates a modification of this graph with some directed edges added. The
    argument must be an array containing the new edges as vertex pairs. Edges
    already present in the graph, as well as pairs of the form `[v,v]`, are
    silently ignored.
    ###
    conjIn = (m, k, v) -> _.assoc(m, k, _.conj(_.get(m, k), v))

    withEdge = (G, [v, w]) ->
      if _.equals(v, w) or G.isEdge(v, w)
        G
      else
        G1 = G.withVertices([v, w])
        new PersistentGraph(
          G1._verts,
          conjIn(G1._pred, w, v),
          conjIn(G1._succ, v, w))

    _.reduce(withEdge, this, es)

  withoutEdges: (es) ->
    ###
    Creates a modification of this graph with some directed edges removed. The
    argument must be an array containing the edges to be removed as vertex
    pairs. Edges not present in this graph are silently ignored.
    ###
    disjIn = (m, k, v) -> _.assoc(m, k, _.disj(_.get(m, k), v))

    withoutEdge = (G, [v, w]) ->
      if not G.isEdge(v, w)
        G
      else
        new PersistentGraph(
          G._verts,
          disjIn(G._pred, w, v),
          disjIn(G._succ, v, w))

    _.reduce(withoutEdge, this, es)


module.exports = (es, vs = []) ->
  ### The factory function this module exports (see above). ###
  g = new PersistentGraph(_.set(), _.hash_map(), _.hash_map())
  g.withEdges(es).withVertices(vs)
