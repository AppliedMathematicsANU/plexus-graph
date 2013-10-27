mori = require 'mori'
trav = require '../src/traversal'


adj = (i) -> [i - 1, i + 2]

console.log mori.take(20, trav.bfs(adj, [0]))
console.log mori.take(20, trav.dfs(adj, [0]))

adj = ([x, y]) -> [[x + 1, y], [x, y + 1]]

console.log mori.take(20, trav.bfs(adj, [[0, 0]]))
console.log mori.take(20, trav.dfs(adj, [[0, 0]]))
