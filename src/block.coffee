# Coord: the actual pixel coordinate
# Position: the grid position
# A block can rotate, flip vertically, flip horizontally
MARGIN = 74
WIDTH = 32
class Blocks
  _playground: {}
  _blocks: {} # buffer for pixi obj

  constructor: (BLOCKS, type, texture) ->
    if type is 'human'
      BLOCKS.map (data, index) =>
        @drawHumanBlock data, index, texture
    else if type is 'ai'
      BLOCKS.map (data, index) =>
        @drawAIBlock data, index, texture

    # @Utest()

  getBlock: (n) ->
    return null if n > 20 or n < 0
    return this._blocks[n]

  flipCoordV: (co) ->
    return [co[0], -co[1]]

  flipCoordH: (co) ->
    return [-co[0], co[1]]

  rotateCoordCW: (co) ->
    return [-co[1], co[0]]

  rotateCoordACW: (co) ->
    return [co[1], -co[0]]

  flipV: (block) =>
    block.coord = block.coord.map (co) =>
      return @flipCoordV(co)
    block.corners = block.corners.map (co) =>
      return @flipCoordV(co)
    block.borders = block.borders.map (co) =>
      return @flipCoordV(co)
    block.cornerDots = block.cornerDots.map (co) =>
      return @flipCoordV(co)

    @updateDots(block)

  flipH: (block) ->
    block.coord = block.coord.map (co) =>
      return @flipCoordH(co)
    block.corners = block.corners.map (co) =>
      return @flipCoordH(co)
    block.borders = block.borders.map (co) =>
      return @flipCoordH(co)
    block.cornerDots = block.cornerDots.map (co) =>
      return @flipCoordH(co)

    @updateDots(block)

  rotateCW: (block) =>
    block.coord = block.coord.map (co) =>
      return @rotateCoordCW(co)
    block.corners = block.corners.map (co) =>
      return @rotateCoordCW(co)
    block.borders = block.borders.map (co) =>
      return @rotateCoordCW(co)
    block.cornerDots = block.cornerDots.map (co) =>
      return @rotateCoordCW(co)

    @updateDots(block)

  rotateACW: (block) =>
    block.coord = block.coord.map (co) =>
      return @rotateCoordACW(co)
    block.corners = block.corners.map (co) =>
      return @rotateCoordACW(co)
    block.borders = block.borders.map (co) =>
      return @rotateCoordACW(co)
    block.cornerDots = block.cornerDots.map (co) =>
      return @rotateCoordACW(co)

    @updateDots(block)

  transBlock: (block, type) ->
    return unless type in ['flipV', 'flipH', 'rotateCW', 'rotateACW']
    this[type](block)
    @place(block, [block.gx, block.gy])

  updateDots: (block) ->
    k = block.coord.length
    block.children.map (dot, i) ->
      if i < k
        dot.position =
          x: block.coord[i][0] * WIDTH
          y: block.coord[i][1] * WIDTH

  computeCorners: (block) ->
    dotHash = {}
    dotArray = []
    corners = []
    borders = []
    cornerDots = new SQ.Fun.Set()

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
        if d[0] isnt pos[0] and d[1] isnt pos[1]
          cornerDots.push [pos[0], pos[1]]
          return true
        else
          return false

      return m.length is n.length

    borders = dotArray.filter (d) ->
      flag = false
      block.coord.map (pos) ->
        flag = true if (d[0] is pos[0] and Math.abs(d[1] - pos[1]) is 1) or (d[1] is pos[1] and Math.abs(d[0] - pos[0]) is 1)
        return pos
      return flag

    return [corners, borders, cornerDots.toArray()]


  getCorners: (block) ->

  getLiveCorner: ->

  getPlacePosition: (pos) ->

  placable: (block, coord) ->
    SQ.playground.placable(block, coord)

  place: (block, coord) ->
    SQ.playground.place(block, coord)
    if SQ.Users.current().isHuman()
      @addControlPanel(block)

  addControlPanel: (block) ->
    return if block.confirm
    offsetx = 80
    Circle = (x, y, radius, frame) ->
      res = new PIXI.Graphics()
      res.lineStyle(0)
      res.beginFill(0xffffff, 1)
      res.drawCircle(0, 0, radius)
      res.endFill()
      res.x = x
      res.y = y
      res.interactive = true
      res.buttonMode = true
      res.hitArea = new PIXI.Rectangle(-10,-10,20,20)

      icon = PIXI.Sprite.fromFrame(frame)
      icon.position.x = -10
      icon.position.y = -10
      res.addChild(icon)

      block.addChild(res)
      return res

    block.fliph = Circle(10 + offsetx, 10, 10, 7)
    block.flipv = Circle(10 + offsetx, 30, 10, 8)
    block.confirm = Circle(30 + offsetx, 10, 10, 9)
    block.cancel = Circle(30 + offsetx, 30, 10, 10)
    block.rotatecw = Circle(50 + offsetx, 10, 10, 5)
    block.rotateacw = Circle(50 + offsetx, 30, 10, 6)

    block.confirm.mouseup = (data) =>
      if SQ.playground.placable(block)
        SQ.playground.finishPlace(block)
      else
        SQ.Anim.play(block, 'shake')

    block.cancel.mouseup = () =>
      SQ.playground.placeBack(block)

    block.fliph.mouseup = (data) =>
      @transBlock(block, 'flipH')

    block.flipv.mouseup = (data) =>
      @transBlock(block, 'flipV')

    block.rotatecw.mouseup = (data) =>
      @transBlock(block, 'rotateCW')

    block.rotateacw.mouseup = (data) =>
      @transBlock(block, 'rotateACW')



  finishPlace: (block, x, y) ->
    SQ.playground.finishPlace(block, x, y)

  unplace: (block) ->
    SQ.playground.unplace(block)

  placeBack: (block) ->
    SQ.playground.placeBack(block)

  getPos: (block) ->
    gx = Math.max(0, Math.round((block.position.x - MARGIN_L) / WIDTH))
    gy = Math.max(0, Math.round((block.position.y - MARGIN_T) / WIDTH))
    return [gx, gy]

  setupTouchEvent: (block) ->
    self = this
    block.mouseover = (data) ->
      block.scale = {x:1, y:1}

    block.mouseout = (data) ->
      return if block.put is true
      block.scale = {x:.5, y:.5}

    block.mousedown = block.touchstart = (data) ->
      this.alpha = 0.8
      this.dragging = true
      block.scale = {x:1, y:1}

      SQ.board.addChild(block)

      this.position.ox = this.position.x
      this.position.oy = this.position.y

    block.mouseup = block.mouseupoutside = block.touchend = block.touchendoutside = (data) ->
      return unless this.dragging
      this.alpha = 1
      this.dragging = false
      block.scale = {x:1, y:1}

      gxy = self.getPos(block)
      # if self.placable(block, gxy)
      self.place(block, gxy)
        # window.alert(gx.toString() + ':' + gy.toString())
      # else
        # self.placeBack(block)

    block.mousemove = block.touchmove = (data) ->
      if this.dragging
        newPosition = data.getLocalPosition this.parent.parent.children[0]
        this.position.x = newPosition.x
        this.position.y = newPosition.y

  computeProp: (block, data, index) ->
    block.coord = data
    block.order = index
    com = @computeCorners(block)
    block.corners = com[0]
    block.borders = com[1]
    block.cornerDots = com[2]


  drawDots: (block, data, color) ->
    data.map (pos, di) ->
      dot = PIXI.Sprite.fromFrame(color)
      dot.interactive = true
      dot.position.x = pos[0] * WIDTH
      dot.position.y = pos[1] * WIDTH
      dot.scale.x = .3
      dot.scale.y = .3
      block.addChild(dot)


  drawAIBlock: (data, index, color) ->
    self = this
    block = new PIXI.DisplayObjectContainer()
    block.type = 'ai'
    block.interactive = true
    block.buttonMode = true

    @drawDots(block, data, color)

    @computeProp(block, data, index)

    self._blocks[index] = block
    return block


  drawHumanBlock: (data, index, color) ->
    self = this
    block = new PIXI.DisplayObjectContainer()
    block.type = 'human'
    block.interactive = true
    block.buttonMode = true
    block.position.x = Math.floor(index / 7) * 70
    block.position.y = (index % 7) * 30 * 3 + 70
    block.position.ox = block.position.x
    block.position.oy = block.position.y
    block.scale = {x:.5, y:.5}

    @drawDots(block, data, color)

    @setupTouchEvent(block)

    @computeProp(block, data, index)

    self._blocks[index] = block
    return block

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
