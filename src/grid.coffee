Grid =
  _grid: []

  dim: 0

  init: (dim, draw, getCoord, randomBlock) ->
    @randomBlock = randomBlock
    @_grid = []
    @dim = dim
    drawGrid = () =>
      for i in [0..dim-1]
        gy = []
        for j in [0..dim-1]
          gy.push getCoord([i, j]).concat([-1, null]);
        @_grid.push gy

      @_grid.map (i,_i) =>
        i.map (j,_j) ->
          draw(j[0], j[1], _j, _i)
          return j
        return i

    drawGrid()
    return @_grid

  # pixel coord
  getCoord: (x, y) ->
    return [MARGIN_L + x * WIDTH, MARGIN_T + y * WIDTH]

  # ordinal coord
  getPosition: (x, y) ->
    gx = Math.max(0, Math.round((x - MARGIN_L) / WIDTH))
    gy = Math.max(0, Math.round((y - MARGIN_T) / WIDTH))
    return [gx, gy]

  getDistance: (x1,y1,x2,y2) ->
    xy1 = @getPosition(x1, y1)
    xy2 = @getPosition(x2, y2)

    return [Math.abs(xy1[0] - xy2[0]), Math.abs(xy1[1] - xy2[1])]

  getNeighbor: (x, y) ->
    x1 = x
    y1 = if y-1 < 0 then 0 else y-1
    x2 = if x+1 > @dim then @dim else x+1
    y2 = y
    x3 = x
    y3 = if y+1 > @dim then @dim else y+1
    x4 = if x-1 < 0 then 0 else x-1
    y4 = y
    return [
      [x1, y1],
      [x2, y2],
      [x3, y3],
      [x4, y4],
      [x4, y1],
      [x2, y1],
      [x2, y3],
      [x4, y3]
    ]

  clearMap: () ->
    for k,v of Landing.map
      v.alpha = .5
      v.marked = false

  markBlock: (xy) ->
    block = Landing.map[xy[0] + ',' + xy[1]]
    block.marked = true
    block.alpha = 1

  place: (block, coord, fromSync) =>
    # ix = Math.floor((x - 74) / 32)
    # iy = Math.floor((y - 74) / 32)
    block.put = true
    pos = @getCoord(coord)

    block.position =
      x: pos[0] - WIDTH / 2
      y: pos[1] - WIDTH / 2

    block.gx = coord[0]
    block.gy = coord[1]

  recur: (x1, y1, x2, y2, g) ->
    return if x1 is x2 and y1 is y2

    around = @getNeighbor(x1, y1)
    cand = around.map (pos) =>
      _x = pos[0]
      _y = pos[1]
      h = Math.abs(x2 - _x) + Math.abs(y2 - _y)
      return {pos: pos, val: g + 1 + h}

    cand = cand.filter (pos) =>
      pos = pos.pos
      block = Landing.map[pos[0] + ',' + pos[1]]
      return unless block
      return block.taken isnt 1 and block.marked isnt true

    cand.sort (a, b) ->
      return if a.val > b.val then 1 else if a.val < b.val then -1 else  0

    # console.log cand[0]
    @markBlock cand[0].pos

    res = cand[0].pos
    if cand[0].val > 50
      console.log 'max lookup distance'
      return
    g += 1
    @recur(res[0], res[1], x2, y2, g)

  astar: (x1, y1, x2, y2) ->
    @_grid.map (g) ->
      return g

    g = 0
    if (@randomBlock[x2 + ',' + y2])
      return
    @recur(x1, y1, x2, y2, g)

  # TODO: astar search with blocks

  getCurrent: () ->
    self = this
    center = @getCoord(10,10)
    stage.mousemove = (data) ->
      newPosition = data.getLocalPosition this.children[0]
      # console.log self.getDistance(center[0], center[1], newPosition.x, newPosition.y)
      target = self.getPosition(newPosition.x, newPosition.y)
      self.clearMap()
      self.astar(10,10,target[0],target[1])
