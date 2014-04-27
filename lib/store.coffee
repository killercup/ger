#Initially a stub of redis Key Value Store. 
# client.sinter
# client.sunion
# client.scard
# client.smembers
# client.sunionstore
# client.sdiff
# client.del
# client.zadd
# client.zscore
# client.zrevrange
# client.zrange
# client.zremrangebyrank
# client.zcard

q = require 'q'
GER_Models = require './models'
SortedSet = GER_Models.SortedSet

class Store
  constructor: (ivals = {}) ->
    @store = ivals

  set: (key, value) ->
    return q.fcall(=> @store[key] = value; return) 
  
  get: (key) ->
    return  q.fcall(=> @store[key])

  #SORTED SET CALLS
  incr_to_sorted_set: (key, value, score) ->
    #redis.zincrby
    @_check_sorted_set(key)
    q.fcall(=> @store[key].increment(value, score); return)

  add_to_sorted_set: (key, value, score=1) ->
    #redis.zadd
    @_check_sorted_set(key)
    q.fcall(=> @store[key].add(value, score); return)

  sorted_set_item_score: (key, value) ->
    if !(key of @store)
      return q.fcall(-> null)
    q.fcall(=> @store[key].score(value))

  _check_sorted_set: (key) ->
    if !(key of @store)
      @store[key] = new SortedSet()

  #SET METHODS
  union: (key1, key2) ->
    q.all([@.get(key1), @.get(key2)])
    .spread((set1, set2) -> set1.union(set2))

  intersection: (key1, key2) ->
    q.all([@.get(key1), @.get(key2)])
    .spread((set1, set2) -> set1.intersection(set2))

  jaccard_metric: (s1,s2) ->
    q.all([@intersection(s1,s2), @union(s1,s2)])
    .spread((int_set, uni_set) -> [int_set.size(), uni_set.size()])
    .spread((int_size,uni_size) -> int_size/uni_size)

#AMD
if (typeof define != 'undefined' && define.amd)
  define([], -> return Store)
#Node
else if (typeof module != 'undefined' && module.exports)
    module.exports = Store;