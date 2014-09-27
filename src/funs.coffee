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
    Object.keys(this.set)