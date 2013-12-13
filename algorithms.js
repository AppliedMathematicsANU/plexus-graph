// Generated by CoffeeScript 1.6.3
/*
This module implements some selected graph algorithms.

Like in the `traversal` module, a graph is specified by a function returning
the list of relevant neighbors for a given vertex and a list of seed
vertices. Details on how arguments are interpreted vary slightly between
functions.

All functions return an array of vertices.
*/

var articulationPoints, bottlenecks, graph, t, topsort, x, _;

_ = require('mori');

x = require('./mori-utils');

t = require('./traversal');

graph = require('./PersistentGraph');

topsort = function(succ, sources) {
  /*
  This function computes a topological vertex order for a finite *DAG*
  (directed acyclic graph). Arguments are the successor function `succ` for
  the graph and a list `sources` of source vertices.
  
  The topological order found is returned as an array if the graph is indeed
  acyclic. Otherwise, `undefined` is returned. Results may not be as expected
  if vertices listed in `sources` are descendants of each other.
  */

  var order, visit;
  visit = function(_arg, v) {
    var marked, order, _ref;
    order = _arg[0], marked = _arg[1];
    if (_.has_key(marked, v)) {
      return [(_.get(marked, v) === 1 ? order : void 0), marked];
    } else {
      _ref = _.reduce(visit, [order, _.assoc(marked, v, 0)], succ(v)), order = _ref[0], marked = _ref[1];
      return [(order != null ? _.conj(order, v) : void 0), _.assoc(marked, v, 1)];
    }
  };
  order = _.reduce(visit, [_.list(), _.hash_map()], sources)[0];
  if (order != null) {
    return _.into_array(order);
  }
};

articulationPoints = function(adj, seeds) {
  /*
  Computes the vertices at which the given finite graph can be 'cut'
  apart. More precisely, a vertex `v` is an articulation point if there are
  vertices `u` and `w` distinct from `v` such that every path between `u` and
  `w` passes through `v`.
  
  Arguments are the adjacency function `adj` for the graph and a list `seeds`
  of seed vertices.
  */

  var edges, good, index, lowPoint, parent, step, trav, vertices;
  edges = t.forest(t.dfs, adj, seeds);
  vertices = _.map(x.second, edges);
  parent = _.zipmap(vertices, _.map(_.first, edges));
  index = _.zipmap(vertices, _.range());
  trav = t.byEdges(t.dfs, adj, seeds);
  step = function(low, _arg) {
    var u, v;
    u = _arg[0], v = _arg[1];
    if ((u != null) && _.get(index, v) >= _.get(index, u)) {
      return _.assoc(low, u, Math.min(_.get(low, u), _.get(low, v)));
    } else if ((u != null) && !_.equals(v, _.get(parent, u))) {
      return _.assoc(low, u, Math.min(_.get(low, u), _.get(index, v)));
    } else {
      return low;
    }
  };
  lowPoint = _.reduce(step, index, _.reverse(_.map(_.into_array, trav)));
  good = function(v) {
    var test;
    if (_.get(parent, v) === null) {
      return x.countAtLeast(2, _.filter((function(w) {
        return _.equals(_.get(parent, w), v);
      }), adj(v)));
    } else {
      test = function(w) {
        return _.equals(_.get(parent, w), v) && _.get(lowPoint, w) >= _.get(index, v);
      };
      return x.any(test, adj(v));
    }
  };
  return _.into_array(_.filter(good, vertices));
};

bottlenecks = function(succ, sources) {
  /*
  Computes the bottlenecks of a finite directed graph. A bottleneck is a
  vertex `v` such that no descendant of `v` can be reached from any source
  vertex by a directed path that does not pass through `v`.
  
  Arguments are the successor function `succ` for the graph and the list
  `sources` of source vertices. Results may not be as expected if vertices
  listed in `sources` are descendants of each other.
  */

  var G, candidates, edges, ends, good, goodEdges, links, succx;
  edges = t.forest(t.dfs, succ, sources);
  goodEdges = _.filter((function(_arg) {
    var v, w;
    v = _arg[0], w = _arg[1];
    return v !== null;
  }), _.map(_.into_array, edges));
  G = graph(goodEdges, sources);
  ends = _.filter((function(v) {
    return G.isSource(v) || G.isSink(v);
  }), G.vertices());
  links = articulationPoints((function(v) {
    return G.adjacent(v);
  }), G.vertices());
  candidates = _.set(_.concat(links, ends));
  succx = function(v) {
    return function(w) {
      if (_.equals(v, w)) {
        return _.set();
      } else {
        return _.disj(_.set(succ(w)), v);
      }
    };
  };
  good = function(v) {
    var descendants, reachable;
    descendants = t.dfs(succ, succ(v));
    reachable = t.dfs(succx(v), sources);
    return x.isEmpty(_.intersection(_.set(descendants), _.set(reachable)));
  };
  return _.into_array(_.filter(good, candidates));
};

module.exports = {
  topsort: topsort,
  articulationPoints: articulationPoints,
  bottlenecks: bottlenecks
};
