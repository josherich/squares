class AI
  constructor: (playground) ->
    @Blocks = playground.AIBlocks
    @startupBlocks = [1,2,3,4,5,6,7,8]
    @availableBlocks = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

    @corners = {}
    @borders = {}
    @grid = {}
    @step = 0
    @turn = 0
    @move = null

    # key gates, try to penetrate them
    @gates = []

  # 2 / 4 person
  mode: 'defaultMode'

  expertRules: []

  strategyMode: []

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

  computeStartValue: (block, cpos) ->
    len = @countCorners(block, cpos)
    lenEnemy = @countCornersEnemy(block, cpos)

    boost = 10
    if (@gates.length > 0)
      arr = block.coord.filter (co) =>
        return co[0] + cpos[0] is @gates[0][0] and co[1] + cpos[1] is @gates[0][1]
      gateScore = if arr.length > 0 then boost else 0
    else
      gateScore = 0

    length = 0
    block.coord.map (co) =>
      length += co[0] + cpos[0] + co[1] + cpos[1]

    # direct boost
    # boost for block that lead to a larger space

    # GATE SCORE
    # big boost for block placed on gate
    # greate boost for block placed on one step from gate
    # if both above impossible, boost for block closest to gate

    return len + lenEnemy * 2 + gateScore + length

  searchGate: (userId) ->
    userId = 0
    console.log('======= gate searching ========')
    for i in [0..DIM-2]
      for j in [0..DIM-2]
        a = SQ.playground.getBlockStat(i, j)
        b = SQ.playground.getBlockStat(i+1, j)
        c = SQ.playground.getBlockStat(i, j+1)
        d = SQ.playground.getBlockStat(i+1, j+1)
        arr = [a,b,c,d].filter (e) ->
          return e is userId
        continue unless (arr.length is 2)

        if (a is userId and d is userId) or (b is userId and c is userId)
          console.info('found: ' + i + '; ' + j + '; ' + userId)
          if SQ.playground.getBlockStat(i,j) is userId
            @gates.push [i,j+1]
          else
            @gates.push [i,j]

  computeValue: (block, cpos) ->
    len = @countCorners(block, cpos)
    lenEnemy = @countCornersEnemy(block, cpos)
    console.log lenEnemy

    return len + lenEnemy * 2

  countCornersEnemy: (block, cpos) ->
    userId = SQ.Users.current().id
    corners = SQ.Fun.copy(SQ.playground.corners)
    c = 0

    for co in block.coord
      pos = [co[0] + cpos[0], co[1] + cpos[1]]
      for k, v of corners[pos.toString()]
        continue if k is userId
        if v is true
          c += 1

    return c

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
          if corners[pos.toString()][userId] is true
            neg += 2
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

  createMove: (block, cpos, stats, dpos, cornerN) ->
    block: block
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

  iterateRotate: (block, cpos) ->
    res = []
    @saveInit(block)

    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos)
        res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeValue(block, cpos))
        # res.push '0,' + dot.toString() + ',' + @computeValue(block, cpos)
      @recoverCoord(block, dot)

    [1,2,3].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos)
          res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeValue(block, cpos)
        @recoverCoord(block, dot)

    @Blocks.flipH(block)
    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos)
        res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeValue(block, cpos))
        # res.push '4,' + dot.toString() + ',' + @computeValue(block, cpos)
      @recoverCoord(block, dot)

    [5,6,7].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos)
          res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeValue(block, cpos)
        @recoverCoord(block, dot)

    @restoreInit(block)

    console.log res
    res


  # param {cpos}: coord of each corner
  # for each pose, try every corner dots, get viable [pose, cornerdot, value]
  iterateRotateStart: (block, cpos) ->
    # res = new SQ.Fun.Set()
    res = []
    @saveInit(block)

    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos)
        res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeStartValue(block, cpos))
        # res.push '0,' + dot.toString() + ',' + @computeStartValue(block, cpos)
      @recoverCoord(block, dot)

    [1,2,3].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos)
          res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeStartValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeStartValue(block, cpos)
        @recoverCoord(block, dot)

    @Blocks.flipH(block)
    block.cornerDots.map (dot) =>
      @adjustCoord(block, dot)
      if @validMove(block) and SQ.playground.placable(block, cpos)
        res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeStartValue(block, cpos))
        # res.push '4,' + dot.toString() + ',' + @computeStartValue(block, cpos)
      @recoverCoord(block, dot)

    [5,6,7].map (i) =>
      @Blocks.rotateCW(block)
      block.cornerDots.map (dot) =>
        @adjustCoord(block, dot)
        if @validMove(block) and SQ.playground.placable(block, cpos)
          res.push @createMove(block.order, cpos, @copyStats(block), dot, @computeStartValue(block, cpos))
          # res.push i + ',' + dot.toString() + ',' + @computeStartValue(block, cpos)
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

  makeMove: (move) =>
    @availableBlocks.splice(@availableBlocks.indexOf(move.block),1)
    block = @getBlock move.block
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
        # @availableBlocks.splice(@availableBlocks.indexOf(index),1)
        return @getBlock(index)

  pickBlocks: () ->
    # for index in [0..20]
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
    @makeMove(move)

  # decide the first 4 or 5 steps before reaching anyone
  computeStartupMoves: ->
    userId = SQ.Users.current().id
    @searchGate(userId)

    block = @pickStartupBlocks()
    res = []

    for cpos in SQ.playground.getCorners()
      arr = @iterateRotateStart(block, cpos)
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
    @makeMove(move)

  computeMoves: ->
    res = []
    for index in @availableBlocks
      block = @getBlock index

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

    move = @pickMove(res)
    unless move
      window.alert('You win, bitch!')
    console.log 'move: block-' + move.block + '; corner(' + move.cpos.toString() + ');' + 'center dot: (' + move.dot.toString() + '); with value: ' + move.cornerN;
    @makeMove(move, block)

  computeEndingMoves: ->

  applyExpertRules: ->

  switchStrategyMode: ->

  compute: () ->
    SQ.playground.ai_on()
    if @turn is 0
      @computeFirstMove()
    else if @turn < 5
      @computeStartupMoves()
    else if @turn >= 5 and @turn < 25
      @computeMoves()
    else if @turn > 17
      @computeEndingMoves()

    setTimeout(SQ.playground.player_on.bind(SQ.playground), 1000)

    console.log("I'm done thinking, bitch!")

    # SQ.playground.step += 1
    # SQ.playground.turn += 1
