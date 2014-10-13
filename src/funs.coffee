Fun = {}

Fun.Set = (array) ->
  this.set = {}
  return unless typeof array is "object" and array.length
  for a in array
    this.set[a.toString()] = true

Fun.Set.prototype =
  push: (a) ->
    this.set[a.toString()] = true

  toArray: () ->
    Object.keys(this.set).map (str) ->
      return str.split(',').map (e) ->
        return parseInt e

Fun.copy = (obj) ->
  res = {}
  for k, v of obj
    if typeof v is 'object'
      res[k] = Fun.copy v
    else
      res[k] = v
  res