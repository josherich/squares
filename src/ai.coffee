class AI
  constructor: (playground) ->
    @Blocks = playground.AIBlocks

  # 2 / 4 person
  mode: 'defaultMode'

  expertRules: []

  strategyMode: []

  startupBlocks: [1,2,3,6,7,8,9,11]

  corners: {}

  borders: {}

  grid: {}

  step: 0

  turn: 0

  move: null

  getBlock: (i) ->
    return null if i < 0 or i > 20
    return SQ.playground.AIBlocks.getBlock i

  updateState: ->
    @turn = SQ.playground.turn
    @computeState()

  withinGrid: (pos) ->
    if pos[0] > -1 and pos[0] < 20 and pos[1] > -1 and pos[1] < 20
      return true
    else
      return false

  # addCorners: (block, x, y) ->
  #   userId = SQ.Users.current().id
  #   corners = {}
  #   for k,v of SQ.playground.corners
  #     corners[k] = v

  #   for c in block.corners
  #     # corners coord has been adjusted
  #     pos = c
  #     if @withinGrid(pos)
  #       if corners[pos.toString()]
  #         corners[pos.toString()][userId] = true
  #       else
  #         corners[pos.toString()] = {}
  #         corners[pos.toString()][userId] = true
  #   Object.keys(corners).length

  addBorders: (block, x, y) ->
    userId = SQ.Users.current().id
    for b in block.borders
      # borders coord has been adjusted
      pos = b
      if @withinGrid(pos)
        if @borders[pos.toString()]
          @borders[pos.toString()][userId] = true
        else
          @borders[pos.toString()] = {}
          @borders[pos.toString()][userId] = true
    console.log(@borders)

  computeState: ->

  computeValue: (block, cpos) ->
    len = @countCorners(block, cpos)

    # len = SQ.playground.addCorners(block, cpos)
    # SQ.playground.removeCorners(block, cpos)

    return len

  countCorners: (block, cpos) ->
    userId = SQ.Users.current().id
    neg = 0
    corners = SQ.Fun.copy(SQ.playground.corners)

    for c in block.corners
      # corners coord has been adjusted
      pos = [c[0] + cpos[0], c[1] + cpos[1]]
      if @withinGrid(pos)
        if corners[pos.toString()]
          if corners[pos.toString()][userId]
            neg += 1
          else
            corners[pos.toString()][userId] = true
        else
          corners[pos.toString()] = {}
          corners[pos.toString()][userId] = true

    # console.log corners

    _corners = {}
    for k, v of corners
      if v[userId] is true
        _corners[k] = v

    Object.keys(_corners).length - neg

  # adjust relative coord to dot[0,0]
  adjustCoord: (block, dot) ->
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

  validMove: (block) ->
    return true if @turn > 0
    flag = true
    block.coord.map (d) ->
      if d[0] < 0 or d[1] < 0
        flag = false
    flag

  makeRotate: (block, n) ->
    n = parseInt n
    if n > 7 or n < 0
      throw new Error('rotate wrong n')

    if n is 0
      return
    if n > 0
      [0...Math.min(n, 3)].map () =>
        @Blocks.rotateCW(block)
    if n > 3
      @Blocks.flipH(block)
    if n > 4
      [4...n].map () =>
        @Blocks.rotateCW(block)

  moveString: (cpos, rotateN, dpos, cornerN) ->
    return [cpos.toString(), rotateN, dpos.toString(), cornerN].join(',')

  # param {cpos}: coord of each corner
  iterateRotate: (block, cpos) ->
    res = new SQ.Fun.Set()

    @saveInit(block)

    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos[0], cpos[1])
        res.push @moveString(cpos, '0', dot, @computeValue(block, cpos))
        # res.push '0,' + dot.toString() + ',' + @computeValue(block, cpos)
      @recoverCoord(block, dot)

    [1,2,3].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos[0], cpos[1])
          res.push @moveString(cpos, i, dot, @computeValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeValue(block, cpos)
        @recoverCoord(block, dot)

    @Blocks.flipH(block)
    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos[0], cpos[1])
        res.push @moveString(cpos, '4', dot, @computeValue(block, cpos))
        # res.push '4,' + dot.toString() + ',' + @computeValue(block, cpos)
      @recoverCoord(block, dot)

    [5,6,7].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos[0], cpos[1])
          res.push @moveString(cpos, i, dot, @computeValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeValue(block, cpos)
        @recoverCoord(block, dot)

    @restoreInit(block)

    console.log res.toArray()
    res.toArray()

  copy: (arr) ->
    res = []
    for a in arr
      res.push a
    return res

  saveInit: (block) ->
    block._coord = @copy block.coord
    block._corners = @copy block.corners
    block._borders = @copy block.borders
    block._cornerDots = @copy block.cornerDots

  restoreInit: (block) ->
    block.coord = block._coord
    block.corners = block._corners
    block.borders = block._borders
    block.cornerDots = block._cornerDots
    @Blocks.updateDots(block)

  makeMove: (move, block) ->
    rotateN = move[2]
    value = move[5]
    @makeRotate(block, rotateN)
    SQ.Users.finishTurn = true

    # SQ.board.addChild(block)
    # SQ.playground.place(block, [move[0], move[1]])
    # SQ.playground.finishPlace(block)
    # SQ.playground.udpateInfoBoard()

    SQ.playground.placeN('ai', block.order, [move[0], move[1]])

  pickMove: (moves) ->
    return moves[0]

  pickStartupBlocks: () ->
    rand = Date.now() % @startupBlocks.length

    for index, i in @startupBlocks
      if i is rand
        @startupBlocks.splice(i, 1)
        return @getBlock(index)

  computeFirstMove: ->
    block = @pickStartupBlocks()

    res = @iterateRotate(block, [0,0])

    console.log res

    res.sort (a, b) ->
      m = parseInt(a[5])
      n = parseInt(b[5])
      if m - n < 0
        return 1
      else if m - n == 0
        return 0
      else if m - n > 0
        return -1

    move = @pickMove(res)
    @makeMove(move, block)

  # decide the first 4 or 5 steps before reaching anyone
  computeStartupMoves: ->
    block = @pickStartupBlocks()
    res = new SQ.Fun.Set()

    for cpos in SQ.playground.getCorners()
      arr = @iterateRotate(block, cpos)
      arr.map (e) ->
        res.push e

    res = res.toArray()

    res.sort (a, b) ->
      m = parseInt(a[5])
      n = parseInt(b[5])
      if m - n < 0
        return 1
      else if m - n == 0
        return 0
      else if m - n > 0
        return -1

    console.log res

    move = @pickMove(res)
    console.log 'move: block-' + block.order + '; corner(' + move[0] + ',' + move[1] + '); with rotate: ' + move[2] + '; center dot: (' + move[3] + ',' + move[4] + '); with value: ' + move[5];
    @makeMove(move, block)

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

    # SQ.playground.step += 1
    # SQ.playground.turn += 1
