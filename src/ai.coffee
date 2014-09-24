class AI
  constructor: (playground) ->

  # 2 / 4 person
  mode: 'defaultMode'

  expertRules: []

  strategyMode: []

  corners: {}

  borders: {}

  grid: {}

  step: 0

  turn: 0

  move: null

  getBlock: (i) ->
    return null if i < 0 or i > 20
    return SQ.playground.Blocks.getBlock i

  updateState: ->
    @turn = SQ.playground.turn
    @computeState()

  withinGrid: (pos) ->
    if pos[0] > -1 and pos[0] < 20 and pos[1] > -1 and pos[1] < 20
      return true
    else
      return false

  addCorners: (block, x, y) ->
    userId = SQ.Users.current().id
    for c in block.corners
      pos = c
      if @withinGrid(pos)
        if @corners[pos.toString()]
          @corners[pos.toString()][userId] = true
        else
          @corners[pos.toString()] = {}
          @corners[pos.toString()][userId] = true
    console.log(@corners)

  addBorders: (block, x, y) ->
    userId = SQ.Users.current().id
    for b in block.borders
      pos = [x + b[0], y + b[1]]
      if @withinGrid(pos)
        if @borders[pos.toString()]
          @borders[pos.toString()][userId] = true
        else
          @borders[pos.toString()] = {}
          @borders[pos.toString()][userId] = true
    console.log(@borders)


  computeState: ->


  computeValue: ->

  countCorners: (block, dot)->
    @addCorners(block, dot[0], dot[1])
    len = Object.keys(@corners).length

    if dot[0] is 0 and dot[1] is 3
      console.log(@corners)

    @corners = []
    return len

  # adjust relative coord to dot[0,0]
  ajustCoord: (block, dot) ->
    block.corners = block.corners.map (d) ->
      return [d[0] - dot[0], d[1] - dot[1]]

    block.borders = block.borders.map (d) ->
      return [d[0] - dot[0], d[1] - dot[1]]

    block.coord = block.coord.map (d) ->
      return [d[0] - dot[0], d[1] - dot[1]]

  recoverCoord: (block, dot) ->
    block.corners = block.corners.map (d) ->
      return [d[0] + dot[0], d[1] + dot[1]]

    block.borders = block.borders.map (d) ->
      return [d[0] + dot[0], d[1] + dot[1]]

    block.coord = block.coord.map (d) ->
      return [d[0] + dot[0], d[1] + dot[1]]

  validFirstMove: (block) ->
    flag = true
    block.coord.map (d) ->
      if d[0] < 0 or d[1] < 0
        flag = false
    flag

  computeFirstMove: ->
    block = null
    rand = Date.now() % 8
    res = []

    [1,2,3,6,7,8,9,11].map (i, index) =>
      if index is rand
        block = @getBlock(i)
        console.log(i)


    console.log block.coord
    console.log block.corners

    SQ.playground.Blocks.rotateCW(block)
    console.log block.coord
    console.log block.corners

    block.cornerDots.map (dot) =>
      @ajustCoord(block, dot)
      if @validFirstMove(block)
        console.log block.corners
        res.push '1,' + dot.toString() + ',' + @countCorners(block, dot)
      @recoverCoord(block, dot)


    SQ.playground.Blocks.rotateCW(block)
    block.cornerDots.map (dot) =>
      @ajustCoord(block, dot)
      if @validFirstMove(block)
        res.push '2,' + dot.toString() + ',' + @countCorners(block, dot)
      @recoverCoord(block, dot)

    SQ.playground.Blocks.rotateCW(block)
    block.cornerDots.map (dot) =>
      @ajustCoord(block, dot)
      if @validFirstMove(block)
        res.push '3,' + dot.toString() + ',' + @countCorners(block, dot)
      @recoverCoord(block, dot)


    res.sort (a, b) ->
      m = parseInt(a.split(',')[3])
      n = parseInt(b.split(',')[3])
      if m - n > 0
        return 1
      else if m - n == 0
        return 0
      else if m - n < 0
        return -1

    move =

    console.log(res)

  # decide the first 4 or 5 steps before reaching anyone
  computeStartupMoves: ->
    [0..11].map (i) =>
      block = @getBlock(i)


  computeMoves: ->


  computeEndingMoves: ->


  applyExpertRules: ->


  switchStrategyMode: ->


  compute: () ->
    if @turn is 0
      @computeFirstMove()
    else if @turn < 5
      @computeStartupMoves()
    else if @turn > 5 and @turn < 18
      @computeMoves()
    else if @turn > 17
      @computeEndingMoves()

    console.log("I'm done thinking, bitch!")
    @makeMove()
    SQ.playground.step += 1
    SQ.playground.turn += 1

    SQ.Users.nextTurn()

  makeMove: () ->
    console.log("I'm done, bitch!")
