class AI
  constructor: (playground) ->
    @Blocks = playground.AIBlocks

  # 2 / 4 person
  mode: 'defaultMode'

  expertRules: []

  strategyMode: []

  startupBlocks: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

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

    return len

  countCorners: (block, cpos) ->
    userId = SQ.Users.current().id
    neg = 0
    corners = SQ.Fun.copy(SQ.playground.corners)

    for c in block.corners
      # corners coord has been adjusted
      pos = [c[0] + cpos[0], c[1] + cpos[1]]
      continue if not SQ.playground.withinGrid(pos) or SQ.playground.blockPlaced(pos)
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
    for k,v in corners
      pos = e.split(',').map (e) -> return parseInt(e)
      if SQ.playground.getStat(pos[0], pos[1]) is 1 or SQ.playground.borders[k][userId]
        delete corners[k]

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

  applyRotate: (block, stats) ->
    block.coord = stats.coord
    block.corners = stats.corners
    block.borders = stats.borders
    block.cornerDots = stats.cornerDots
    @Blocks.updateDots(block)
    # @adjustCoord(block, cdot)

  createMove: (cpos, stats, dpos, cornerN) ->
    cpos: cpos
    stats: stats
    dot: dpos
    cornerN: cornerN

  copyStats: (block) ->
    res = {}
    res.coord = block.coord
    res.corners = block.corners
    res.borders = block.borders
    res.cornerDots = block.cornerDots
    return res

  # param {cpos}: coord of each corner
  # for each pose, try every corner dots, get viable [pose, cornerdot, value]
  iterateRotate: (block, cpos) ->
    # res = new SQ.Fun.Set()
    res = []
    @saveInit(block)

    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos)
        res.push @createMove(cpos, @copyStats(block), dot, @computeValue(block, cpos))
        # res.push '0,' + dot.toString() + ',' + @computeValue(block, cpos)
      @recoverCoord(block, dot)

    [1,2,3].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos)
          res.push @createMove(cpos, @copyStats(block), dot, @computeValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeValue(block, cpos)
        @recoverCoord(block, dot)

    @Blocks.flipH(block)
    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos)
        res.push @createMove(cpos, @copyStats(block), dot, @computeValue(block, cpos))
        # res.push '4,' + dot.toString() + ',' + @computeValue(block, cpos)
      @recoverCoord(block, dot)

    [5,6,7].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos)
          res.push @createMove(cpos, @copyStats(block), dot, @computeValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeValue(block, cpos)
        @recoverCoord(block, dot)

    @restoreInit(block)

    console.log res
    res

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
    @applyRotate(block, move.stats)
    SQ.Users.finishTurn = true

    # SQ.board.addChild(block)
    # SQ.playground.place(block, [move[0], move[1]])
    # SQ.playground.finishPlace(block)
    # SQ.playground.udpateInfoBoard()

    SQ.playground.placeN('ai', block.order, move.cpos)

  pickMove: (moves) ->
    return moves[0]

  pickStartupBlocks: () ->
    rand = Date.now() % @startupBlocks.length

    for index, i in @startupBlocks
      if i is rand
        @startupBlocks.splice(i, 1)
        return @getBlock(index)

  pickBlocks: () ->
    # iterate block from current user blocks
    # computeMove(block)

  computeFirstMove: ->
    block = @pickStartupBlocks()

    res = @iterateRotate(block, [0,0])

    res.sort (a, b) ->
      m = parseInt(a.cornerN)
      n = parseInt(b.cornerN)
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
    res = []

    for cpos in SQ.playground.getCorners()
      arr = @iterateRotate(block, cpos)
      arr.map (e) ->
        res.push e

    res.sort (a, b) ->
      m = parseInt(a.cornerN)
      n = parseInt(b.cornerN)
      if m - n < 0
        return 1
      else if m - n == 0
        return 0
      else if m - n > 0
        return -1

    console.log res

    move = @pickMove(res)
    unless move
      window.alert('You win, bitch!')
    console.log 'move: block-' + block.order + '; corner(' + move.cpos.toString() + ');' + 'center dot: (' + move.dot.toString() + '); with value: ' + move.cornerN;
    @makeMove(move, block)

  computeMoves: ->
    block = @pickBlocks()



  computeEndingMoves: ->


  applyExpertRules: ->


  switchStrategyMode: ->


  compute: () ->
    if @turn is 0
      @computeFirstMove()
    else if @turn < 20
      @computeStartupMoves()
    else if @turn > 20 and @turn < 25
      @computeMoves()
    else if @turn > 17
      @computeEndingMoves()

    console.log("I'm done thinking, bitch!")

    # SQ.playground.step += 1
    # SQ.playground.turn += 1
