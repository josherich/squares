# Coord: the actual pixel coordinate
# Position: the grid position
# A block can rotate, flip vertically, flip horizontally
MARGIN = 74
WIDTH = 32
class Blocks
  _playground: {}
  _blocks: {} # buffer for pixi obj

  constructor: (blocks, callback, Users, playground) ->
    @callback = callback
    @Users = Users

    @drawBlocks(blocks)

    @Utest()
    @setUI()

  getBlock: (n) ->
    return null if n > 20 or n < 0
    return this._blocks[n]

  flipCoordV: (co) ->
    return [co[0], -co[1]]

  flipCoordH: (co) ->
    return [-co[0], co[1]]

  flipV: (block) =>
    block.coord = block.coord.map (co) =>
      return @flipCoordV(co)
    @updateDots(block)

  flipH: (block) ->
    block.coord = block.coord.map (co) =>
      return @flipCoordH(co)
    @updateDots(block)

  rotateCoord: (co) ->
    return [-co[1], co[0]]

  rotateBlock: (block) =>
    block.coord = block.coord.map (co) =>
      return @rotateCoord(co)
    @updateDots(block)

  updateDots: (block) ->
    block.children.map (dot, i) ->
      dot.position =
        x: block.coord[i][0]
        y: block.coord[i][1]

  computeCorners: (block) ->
    dotHash = {}
    dotArray = []
    corners = []
    borders = []
    tempMap = {}
    block.coord.map (pos) ->
      tempMap[pos.toString()] = 1

    # coord = block.coord.map (pos) ->
      # return [block.gx + pos[0], block.gy + pos[1]]
    getRoundCoord = (pos) ->
      gx = pos[0]
      gy = pos[1]
      result = []
      result.push([gx, gy-1]) # top
      result.push([gx+1, gy-1]) # top-right
      result.push([gx+1, gy]) # right
      result.push([gx+1, gy+1]) # right-bottom
      result.push([gx, gy+1]) # bottom
      result.push([gx-1, gy+1]) # bottom-left
      result.push([gx-1, gy]) # left
      result.push([gx-1, gy-1]) # left-top
      result

    pushSet = (set, round) ->
      for d in round
        set[d.toString()] = true

    block.coord.map (e) ->
      round = getRoundCoord(e).filter (pos) ->
        return tempMap[pos.toString()] is undefined
        # return SQ.playground.getStat(pos[0], pos[1]) is 0
      pushSet(dotHash, round)

    for s of dotHash
      dotArray.push s.split(',').map (e) ->
        return parseInt(e)

    corners = dotArray.filter (d) ->
      round = getRoundCoord(d)
      n = round.filter (pos) ->
        return tempMap[pos.toString()] is 1
        # return SQ.playground.getStat(pos[0], pos[1]) is 1
      # TODO get dots other than corners
      m = n.filter (pos) ->
        return d[0] isnt pos[0] and d[1] isnt pos[1]

      return m.length is 1 and n.length is 1

    borders = dotArray.filter (d) ->
      flag = false
      block.coord.map (pos) ->
        flag = true if (d[0] is pos[0] and Math.abs(d[1] - pos[1]) is 1) or (d[1] is pos[1] and Math.abs(d[0] - pos[0]) is 1)
        return pos
      return flag

    console.log(borders)
    return [corners, borders]


  getCorners: (block) ->

  getLiveCorner: ->

  getPlacePosition: (pos) ->

  placable: (block, x, y) ->
    SQ.playground.placable(block, x, y)

  place: (block, x, y) ->
    SQ.playground.place(block, x, y)

  unplace: (block) ->
    SQ.playground.unplace(block)

  placeBack: (block) ->
    SQ.playground.placeBack(block)

  getPos: (block) ->
    gx = Math.max(0, Math.round((block.position.x - MARGIN) / WIDTH))
    gy = Math.max(0, Math.round((block.position.y - MARGIN) / WIDTH))
    return [gx, gy]

  drawBlocks: (blocks) ->
    self = this
    SQ.panel = blockPanel = new PIXI.DisplayObjectContainer()
    blockPanel.position.x = 788 - 60
    blockPanel.position.y = 10
    blockPanel.width = 32
    blockPanel.height = 700
    blockPanel.interactive = true
    # blockPanel.hitArea = new PIXI.Rectangle(788-60, 10, 32, 700)

    # blockPanel.mouseover = blockPanel.mousedown = blockPanel.touchstart = (data) ->
    #   console.log data

    blocks.map (b, bi) ->
      block = new PIXI.DisplayObjectContainer()
      block.interactive = true
      block.buttonMode = true
      block.position.x = Math.floor(bi / 7) * 70
      block.position.y = (bi % 7) * 32 * 3 + 70
      block.position.ox = block.position.x
      block.position.oy = block.position.y
      block.scale = {x:.5, y:.5}
      block.coord = b

      b.map (pos, di) ->
        dot = PIXI.Sprite.fromFrame(0)
        dot.interactive = true
        dot.position.x = pos[0] * 32
        dot.position.y = pos[1] * 32

        # dot.mouseover = (data) ->

        block.addChild(dot)

      block.mouseover = (data) ->
        block.scale = {x:1, y:1}

      block.mouseout = (data) ->
        return if block.put is true
        block.scale = {x:.5, y:.5}

      block.mousedown = block.touchstart = (data) ->
        this.alpha = 0.8
        this.dragging = true
        block.scale = {x:1, y:1}
        if block.put
          self.unplace(block)
        else
          SQ.board.addChild(block)

        this.position.ox = this.position.x
        this.position.oy = this.position.y

      block.mouseup = block.mouseupoutside = block.touchend = block.touchendoutside = (data) ->
        return unless this.dragging
        this.alpha = 1
        this.dragging = false
        block.scale = {x:1, y:1}

        gxy = self.getPos(block)
        if self.placable(block, gxy[0], gxy[1])
          self.place(block, gxy[0], gxy[1])
          # window.alert(gx.toString() + ':' + gy.toString())
        else
          self.placeBack(block)

      block.mousemove = block.touchmove = (data) ->
        if this.dragging
          newPosition = data.getLocalPosition this.parent.parent.children[0]
          this.position.x = newPosition.x
          this.position.y = newPosition.y
      console.log(bi + ' compute :')
      com = self.computeCorners(block)
      block.corners = com[0]
      block.borders = com[1]

      self._blocks[bi] = block

      blockPanel.addChild(block)

    stage.addChild(blockPanel)

  logger: ->
    $('.row')[0].innerText = 'follower placed: ' + @currentBlock.followerPlaced.toLocaleString()
    $('.row')[1].innerText = 'edges: ' + @currentBlock.edges.toLocaleString()
    console.log @currentBlock
    console.log @__blocks

  randomize: (blocks) ->
    for i in [1..100]
      n = Math.floor(Math.random() * 56)
      removed = blocks.splice(n, 1)
      blocks.push(removed[0])

  Utest: ->

  loadResource: ->
    followers = []
    for i in [1..6]
      texture = PIXI.Texture.fromImage('images/player-' + i + '.png')
      PIXI.Texture.addTextureToCache(texture, i)

  setUI: ->
    # what is plate?
    # @plate = new PIXI.DisplayObjectContainer()
    # @plate.setInteractive true
    # stage.addChild(@plate)

    # BUTTON finish
    # BUTTON cancel

    # document.querySelectorAll('#block')[0].addEventListener "click", (event) =>
    #   @donePlace()
    #   @drawPlacable()
    #   @drawFollower()
    #   $('#block').hide()
    #   $('#follower').show()
    # # stage.addChild(donePlace)

    # # doneFollower = new PIXI.Text("confirm follower", {font: "25px Arial", align: "right"})
    # # doneFollower.setInteractive true
    # # doneFollower.buttonMode = true
    # # doneFollower.position.x = 800
    # # doneFollower.position.y = 200
    # # doneFollower.click = doneFollower.touchstart = =>
    # document.querySelectorAll('#follower')[0].addEventListener "click", (event) =>
    #   @donePlaceFollower(@callback)
    #   $('#follower').hide()
    # # stage.addChild(doneFollower)
    # @bindKey()

    # @place(4, 4, @_blocks[27])
    # @donePlace()
    # @drawPlacable()
    # @drawFollower()

  # 0 is none; 1 is placable, 2 block is placed, 3 is unplacable
  # [grid-x, grid-y, status, blockObj]


class old
  makeBlock: (data) ->
    img = data[0]
    texture = PIXI.Rectangle()
    for i in [1..data[1]]
      @makeOneBlock(texture, data)

  makeOneBlock: (texture, data) ->
    self = this
    block = new PIXI.Sprite(texture)
    block.setInteractive true
    block.buttonMode = true

    block.edges = data[3].slice()
    block.edgeTypes = data[4].slice()
    block.followerPlaced = [0,0,0,0]
    block.cloister = false
    block.fields = data[5].map (f) ->
      res = {}
      res.pos = f[0..1]
      res.edges = f[2]
      res.marked = false
      res.takenBy = 0
      return res

    block.seats = data[6].map (f) ->
      block.cloister = true if f[2].length is 0
      res = []
      res.push(f[0])
      res.push(f[1])
      res.push(f[2].slice())
      return res

    block.follower = null

    block.rotation = 0
    block.rotationN = 0

    block.scale.x = block.scale.x / 1.11
    block.scale.y = block.scale.y / 1.11

    block.mousedown = block.touchstart = (data) ->
      this.data = data
      this.alpha = 0.8
      this.dragging = true
      this.position.ox = this.position.x
      this.position.oy = this.position.y

    block.mouseup = block.mouseupoutside = block.touchend = block.touchendoutside = (data) ->
      this.alpha = 1
      this.dragging = false
      this.data = null
      gx = Math.max(0, Math.round(this.position.x / 100) - 1)
      gy = Math.max(0, Math.round(this.position.y / 100) - 1)

      if self.isPlacable(gx, gy)
        self.place(gx, gy, this)
        $('#block').show()
      else
        this.position.x = this.position.ox
        this.position.y = this.position.oy

    block.mousemove = block.touchmove = (data) ->
      if this.dragging
        newPosition = this.data.getLocalPosition this.parent
        this.position.x = newPosition.x
        this.position.y = newPosition.y

    block.anchor.x = 0.5
    block.anchor.y = 0.5
    block.position.x = 100
    block.position.y = 100
    block.value = if data[2] is 0 then 1 else 2

    stage.addChild(block)
    @_blocks.push(block)

  isPlacable: (gx, gy) ->
    @grid[gx][gy][2] == B_PLACEBLE

  place: (gx, gy, block) ->
    # update the block in this unit
    # if @grid[gx][gy][3]?
    #   stage.removeChild(@grid[gx][gy][3])
    # stage.addChild(block)
    @plate.addChild(block)
    x = (gx + 1) * 100
    y = (gy + 1) * 100
    block.position.x = x
    block.position.y = y

    block.gx = gx
    block.gy = gy

    @currentBlock = block
    @__blocks.push(@currentBlock)
    @nextBlock = @_blocks[@_blocks.length-1]
    @_blocks.pop()

    @setRotation(@grid[gx][gy][4])

  # finish palce a block, rotate
  donePlace: () ->
    block = @currentBlock
    gx = block.gx
    gy = block.gy

    @rotateEdgeInfo(block)
    @rotateEdge8(block)

    # you cannot move it anymore once you confirm
    block.mousedown = block.touchstart = block.mouseup = block.mousemove = block.mouseupoutside = block.touchend = block.touchendoutside = null
    block.click = block.touchstart = null

    @grid[gx][gy][2] = B_PLACED
    @grid[gx][gy][3] = block
    @updateEdges(gx, gy)
    $('#rotate').unbind('click')
    @plate.addChild(block)

  rotateEdgeInfo: (block) ->
    n = block.rotationN

    block.edges = @rotate(block.edges, n)
    block.edgeTypes = @rotate(block.edgeTypes, n)
    for s in block.seats
      s[2] = @rotate(s[2], n)
    console.log 'rotate the edges and connectInfo with: ' + n

  rotateEdge8: (block) ->
    n = block.rotationN

    for f in block.fields
      f.edges = f.edges.map (e) ->
        return (e + n * 2) % 8
    return

  # iterate all edges, draw placable block for next block
  drawPlacable: ->
    for e in @_edgeBlocks
      gx = e[0]
      gy = e[1]

      edges = @getEdges(gx, gy)
      angels = @getMatchAngels(edges)

      # update _edgeBlocks: remove and update prev info
      if @grid[gx][gy][3]?
        if angels.length is 0 and @grid[gx][gy][2] is 1
          @plate.removeChild(@grid[gx][gy][3])
          @grid[gx][gy][3] = null
          @grid[gx][gy][2] = 0
        else
          @grid[gx][gy][4] = angels

      # add new placable
      if @grid[gx][gy][2] is 0 and angels.length > 0
        texture = PIXI.Texture.fromImage('images/placable.png')
        placable = new PIXI.Sprite texture
        placable.scale.x = placable.scale.x / 1.11
        placable.scale.y = placable.scale.y / 1.11
        placable.anchor.x = 0.5
        placable.anchor.y = 0.5

        placable.position.x = @grid[gx][gy][0]
        placable.position.y = @grid[gx][gy][1]
        # console.log @grid[gx][gy][0] + '; ' + @grid[gx][gy][1]
        @grid[gx][gy][2] = 1
        @grid[gx][gy][3] = placable
        @grid[gx][gy][4] = angels
        # console.debug 'angels for pos: %s, %s: ', gx, gy
        # console.debug angels
        @plate.addChild(placable)
        # stage.addChild(placable)

  drawFollower: ->
    self = this
    seats = @getAvailableSeats()
    # fields = @getAvailableFields()
    console.log seats

    for s in seats
      texture = PIXI.Texture.fromImage('images/follower.png')
      blank = new PIXI.Sprite texture
      blank.setInteractive true
      blank.scale.x = blank.scale.x / 1.11
      blank.scale.y = blank.scale.y / 1.11
      blank.alpha = 0.5
      blank.anchor.x = 0.5
      blank.anchor.y = 0.5
      blank.buttonMode = true

      blank.position.x = - 50 + s[0]
      blank.position.y = - 50 + s[1]

      blank.pos = s[2] # type: road, castle or field
      blank.fieldIndex = s[3] if s[3]?

      blank.click = blank.touchstart = ->
        console.log 'click event'
        console.log blank.position.x + ';' + blank.position.y
        self.placeFollower(this)
      @pool.push(blank)
      @currentBlock.addChild(blank)

  placeFollower: (blank) ->
    @currentBlock.removeChild(@currentFollower) if @currentFollower?

    follower = new PIXI.Sprite.fromFrame @currentUser.id
    follower.setInteractive true
    follower.scale.x = follower.scale.x / 6
    follower.scale.y = follower.scale.y / 6
    follower.anchor.x = 0.5
    follower.anchor.y = 0.5
    follower.position.x = blank.position.x
    follower.position.y = blank.position.y
    follower.user = @currentUser

    @currentFollower = follower
    if blank.fieldIndex?
      @currentBlock.fields[blank.fieldIndex].takenBy = @currentUser.id
      @currentBlock.followerPlaced = [0,0,0,0]
    else
      @currentBlock.followerPlaced = @getFollowerState(blank.pos)

    @currentBlock.follower = follower
    @currentBlock.addChild(follower)

  donePlaceFollower: (callback) =>
    @clearPool()

    @renderScore()
    @currentFollower = null
    #finish one round, to next player
    callback()

# Util
  updateEdges: (gx, gy) ->
    for e, i in @_edgeBlocks
      if e[0] is gx and e[1] is gy
        @_edgeBlocks.splice(i,1)
        break

    for e in @getNeighbors(gx, gy)
      @_edgeBlocks.push e if @grid[e[0]][e[1]][2] is 0

  setRotation: (angels) ->
    console.debug '=== in setRotation === '
    console.debug angels
    return unless angels?
    block = @currentBlock
    block.rotation = angels[0] * Math.PI/2
    block.rotationN = angels[0]

    i = 1
    $('#rotate').click ->
      a = angels[i % angels.length]
      block.rotation = a * Math.PI/2
      block.rotationN = a
      i++

  getAvailableSeats: ->
    seats = []
    n = if @currentBlock.rotationN? then @currentBlock.rotationN else 0

    for s in @currentBlock.seats
      for e, i in s[2]
        if e is 1 and @currentBlock.edges[i] is E_ROAD
          @probeRoad(@currentBlock, s, i, false)
          seats.push(s) if !@roadTaken and seats.indexOf(s) is -1 # avoid push twice

        if e is 1 and @currentBlock.edges[i] is E_CASTLE
          @castleDFS(@currentBlock, s, false)
          seats.push(s) if !@castleTaken and seats.indexOf(s) is -1
          continue

    for f, i in @currentBlock.fields
      @probeField(@currentBlock, f)
      seats.push([f.pos[0], f.pos[1], f.edges, i]) if !@fieldTaken
    console.debug '=== castle dfs ==='
    seats

  renderScore: ->
    for s in @currentBlock.seats
      for e, i in s[2]
        if e is 1 and @currentBlock.edges[i] is E_ROAD
          @probeRoad(@currentBlock, s, i, true)
        if e is 1 and @currentBlock.edges[i] is E_CASTLE
          @castleDFS(@currentBlock, s, true)
    return

  # ========== Helpers ==========

  getFollowerState: (followerState) ->
    self = this
    followerState.map (f) ->
      if f is 1 then return self.currentUser.id else return 0

  isComplete: (block) ->
    for b in @getNeighbors8(block.gx, block.gy)
      return false unless @grid[b[0]][b[1]][3]?
    return true

  clearPool: ->
    for obj in @pool
      @currentBlock.removeChild(obj)
    @pool = []

  hasBlockLeft: ->
    @_blocks.length > 0

  # get placed block by cord
  getBlock: (cord) ->
    status = @grid[cord[0]][cord[1]][2]
    block = @grid[cord[0]][cord[1]][3]
    if status is B_PLACED then block else null

  # get edges type, like [3,2,3,3], [3,null,null,null]
  getEdges: (gx, gy) ->
    neighbors = @getNeighbors(gx, gy)
    edges = []
    edges.push(if @getBlock(neighbors[0])? then @getBlock(neighbors[0]).edges[2] else null)
    edges.push(if @getBlock(neighbors[1])? then @getBlock(neighbors[1]).edges[3] else null)
    edges.push(if @getBlock(neighbors[2])? then @getBlock(neighbors[2]).edges[0] else null)
    edges.push(if @getBlock(neighbors[3])? then @getBlock(neighbors[3]).edges[1] else null)
    edges

  getNeighbors: (gx, gy) ->
    result = []
    result.push([gx, gy-1]) # top
    result.push([gx+1, gy]) # right
    result.push([gx, gy+1]) # bottom
    result.push([gx-1, gy]) # left
    result

  getNeighbors8: (gx, gy) ->
    result = []
    result.push([gx, gy-1]) # top
    result.push([gx+1, gy-1]) # top-right
    result.push([gx+1, gy]) # right
    result.push([gx+1, gy+1]) # right-bottom
    result.push([gx, gy+1]) # bottom
    result.push([gx-1, gy+1]) # bottom-left
    result.push([gx-1, gy]) # left
    result.push([gx-1, gy-1]) # left-top
    result

  getMatchAngels: (edges) ->
    # console.debug edges
    # console.group 'match'
    console.log @nextBlock.edges
    angels = []
    for i in [0..3]
      j = 0
      for j in [i..i+3]
        index = j % 4
        # console.log edges[index] + '; ' + @nextBlock.edges[j-i]
        break if edges[index] isnt @nextBlock.edges[j - i] and edges[index] isnt null
      # console.log 'i: ' + i + '; ' + 'j: ' + j
      angels.push(i) if j is i+4
    # console.groupEnd()
    # console.debug angels
    angels

  getContra: (pos) ->
    dic = [2,3,0,1]
    dic[pos] # dot notation doesnt work

  getContra8: (pos) ->
    dic = [5,4,7,6,1,0,3,2]
    dic[pos]

  rotate: (array, n) ->
    return array if n is 0
    for i in [1..n]
      e = array.pop()
      array.unshift(e)
    return array

  # ========== Castle ===========
  castleDFS: (src, seat, ifRender) ->
    @probeBlocks = []
    @castleTaken = false
    @castleCompleted = true

    @_score = src.value
    @clearMarked()

    src.marked = true

    for e, i in seat[2]
      continue unless e is 1
      if src.edgeTypes[i] is END
        nextBlock = @getNeighborCastles(src.gx, src.gy)[i]

        if nextBlock is null
          @castleCompleted = false
          @castleTaken = false
          break

        # add self if it's an end and placed a follower
        if src.followerPlaced[i] isnt 0
          @probeBlocks.push(src)

        if nextBlock.edgeTypes[@getContra(i)] is END
          if nextBlock.followerPlaced[@getContra(i)] isnt 0
            @probeBlocks.push(nextBlock)
            @castleTaken = true
          @_score += nextBlock.value
          continue
        else
          @_score += nextBlock.value
          @_castleDFS(nextBlock)
      else
        @_castleDFS(src)

    @renderFinished(@_score, 'castle') if ifRender and @castleCompleted is true

  _castleDFS: (block) ->
    block.marked = true
    neighborCastles = @getNeighborCastles(block.gx, block.gy)

    for b, i in neighborCastles
      if b is null
        if block.edges[i] is E_CASTLE
          @castleCompleted = false
        continue
      @_score += b.value unless b.marked

      takenBy = b.followerPlaced[@getContra(i)] # TODO fix get follower
      if takenBy isnt 0
        @probeBlocks.push(b)
        @castleTaken = true

      @_castleDFS(b) unless b.marked

  # [null, 3, 2, 2] => [null, null, block, block]
  getNeighborCastles: (gx, gy) ->
    neighbors = @getNeighbors(gx, gy)
    edges = @getEdges(gx, gy)
    res = []
    res.push(if edges[0] is E_CASTLE then @getBlock(neighbors[0]) else null)
    res.push(if edges[1] is E_CASTLE then @getBlock(neighbors[1]) else null)
    res.push(if edges[2] is E_CASTLE then @getBlock(neighbors[2]) else null)
    res.push(if edges[3] is E_CASTLE then @getBlock(neighbors[3]) else null)
    res

  clearMarked: ->
    for b in @__blocks
      b.marked = false

  # ========== Road ==========
  probeRoad: (block, seat, pos, ifRender) ->
    @probeBlocks = []
    @roadTaken = false
    @roadCompleted = true

    @endCount = 0

    start = [block.gx, block.gy]
    startEdgeType = block.edgeTypes[pos]
    score = 1

    # not an end
    if startEdgeType < END
      for s, i in seat[2]
        otherEndPos = i if s is 1 and i isnt pos # [0,1,1,0]
      # console.log 'probe the other side'
      @_probeRoad(block, start, startEdgeType, score, otherEndPos, ifRender)

    @_probeRoad(block, start, startEdgeType, score, pos, ifRender)

  _probeRoad: (block, start, startEdgeType, score, pos, ifRender)->
    # console.log 'pos: ' + pos
    neighbors = @getNeighbors(block.gx, block.gy)
    gx = neighbors[pos][0]
    gy = neighbors[pos][1]

    # console.info 'next block: ' + gx + '; ' + gy

    nextBlock = if @grid[gx][gy][2] is B_PLACED then @grid[gx][gy][3] else null

    if not nextBlock?
      @roadCompleted = false
      @probeBlocks = [] # clear the probe blocks cache
      return false
    @probeBlocks.push(block) if block.edgeTypes[pos] is END and block.followerPlaced[pos] isnt 0 # push self
    @probeBlocks.push(nextBlock) if nextBlock.follower? and nextBlock.followerPlaced[@getContra(pos)] isnt 0
    # console.log @probeBlocks

    score += 1

    nextEdge = nextBlock.edgeTypes[@getContra(pos)] # 4 endpoint; 5 grass; 0123 other side of the road
    placedBy = nextBlock.followerPlaced[@getContra(pos)] # TODO change this workaround

    # console.log nextBlock.followerPlaced
    # console.log 'placedBy: %s', placedBy
    @roadTaken = true unless placedBy is 0

    if nextEdge < END
      nextEdge = (@getContra(pos) + nextEdge) % 4
      @roadTakenBy[placedBy] += 1 if placedBy?
      @_probeRoad(nextBlock, start, startEdgeType, score, nextEdge, ifRender)
    else if nextEdge is END
      @endCount += 1
      # start with an end, a circle, or probe two ends
      if startEdgeType is END or [gx, gy] is start or @endCount is 2
        @renderFinished(score, 'road') if ifRender
      return false
    else
      console.log 'error in edgeType'
      return false


  renderFinished: (score, type) ->
    taken = [0,0,0,0,0,0] # calculate who get the score
    console.debug '=== render finished ==='
    console.debug @probeBlocks
    for b in @probeBlocks
      for id in b.followerPlaced
        if id isnt 0
          taken[id - 1] += 1
          break
      if b.follower?
        b.removeChild(b.follower)
        b.followerPlaced = [0,0,0,0]

    scorers = @calScorers(taken)

    score = score * 2 if type is 'castle'
    for user in scorers
      @Users.scoring(type, user, score)
    @udpateScoreBoard()

    @probeBlocks = []

  udpateScoreBoard: ->
    document.querySelectorAll('#u1')[0].innerText = @Users.getScore(1)
    document.querySelectorAll('#u2')[0].innerText = @Users.getScore(2)
    document.querySelectorAll('#u3')[0].innerText = @Users.getScore(3)
    document.querySelectorAll('#u4')[0].innerText = @Users.getScore(4)
    document.querySelectorAll('#u5')[0].innerText = @Users.getScore(5)
    document.querySelectorAll('#u6')[0].innerText = @Users.getScore(6)

  calScorers: (users) ->
    max = 1
    hosts = []

    for num in [0..5]
      if users[num] > max
        max = users[num]
        hosts.clear
        hosts.push num+1
      if users[num] is max
        hosts.push num+1
    hosts

  # ========== Field ==========
  probeField: (block, field) ->
    @fieldTaken = false
    @probeBlocks = []
    @_score = 0
    @clearFieldMarked()

    @_probeField(block, field)

    @renderField()

  _probeField: (block, field) ->
    field.marked = true
    for edge in field.edges
      edgeFour = Math.floor(edge / 2)
      nextBlock = @getBlock @getNeighbors(block.gx, block.gy)[edgeFour]
      continue unless nextBlock?

      nextField = @getNeighborFields(nextBlock, edge)
      if @getContra8(edge) in nextField.edges and nextField.takenBy > 0
        @fieldTaken = true
        @probeBlocks.push(block)
        return

      @_probeField(nextBlock, nextField) unless nextField.marked

  getNeighborFields: (nextBlock, edge) ->
    edgeFour = Math.floor(edge / 2)
    for field in nextBlock.fields
      if @getContra8(edge) in field.edges then return field else continue
    console.log 'error in finding next field'

  clearFieldMarked: ->
    for b in @__blocks
      for f in b.fields
        f.marked = false

  renderField: ->
    console.log @probeBlocks
    console.log @fieldTaken
