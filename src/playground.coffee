assert = (test, name) ->
  name = name || 'default assert'
  console.assert(test, name)

isPaused = false

play = ->
  for type, func of Animation.stack
    func() unless func is null

animate = ->
  update() if isPaused
  play()
  renderer.render(stage)
  requestAnimFrame(animate)

PIXI.Texture.Draw = (cb) ->
  canvas = document.createElement('canvas')
  if typeof cb is 'function'
    cb(canvas)
  return PIXI.Texture.fromCanvas(canvas)

MARGIN_L = 274
MARGIN_T = 74
WIDTH = 30
DIM = 14

BLOCK = [

  [[0,0], [0,1], [0,2], [0,3], [0,4]],
  [[0,0], [0,1], [1,1], [1,2], [1,3]],
  [[0,0], [0,1], [0,2], [1,2], [2,2]],
  [[0,0], [1,0], [2,0], [1,1], [1,2]],
  [[0,0], [1,0], [1,1], [1,2], [0,2]],
  [[0,0], [1,0], [1,1], [1,2], [1,3]],
  [[0,0], [0,1], [1,1], [0,2], [0,3]],
  [[0,0], [1,0], [1,1], [1,2], [2,2]],
  [[0,0], [1,0], [1,1], [2,1], [2,2]],
  [[0,0], [0,1], [1,0], [1,1], [0,2]],
  [[0,0], [0,1], [1,0], [0,-1], [-1,0]],
  [[0,0], [0,1], [1,1], [2,1], [1,2]],
  [[0,0], [0,1], [1,1], [1,2]],
  [[0,0], [0,1], [0,2], [0,3]],
  [[0,0], [0,1], [0,2], [1,2]],
  [[0,0], [0,1], [1,0], [1,1]],
  [[0,0], [0,1], [1,1], [0,2]],
  [[0,0], [0,1], [0,2]],
  [[0,0], [0,1], [1,1]],
  [[0,0], [0,1]],
  [[0,0]],
  ];

class Playground
  constructor: ()->
    @corners = {}
    @borders = {}
    @Block_el = {}
    @Users = {}
    @Grid = []
    @currentPlayer = {}
    @turn = 0
    @step = 0

    @initUser(2)
    @drawBackground()
    @initContainer()
    @initGameControl()
    # @initFBSync()
    @loadResource () =>
      @initGrid()
      @initPlayerState()
      @initHumanBlock BLOCK, 0

      @drawBlockPanel(BLOCK)
      @initAIBlock BLOCK, 1

      SQ.AI = new AI(this)

      @UnitTest()
      requestAnimFrame(animate)

  Block_el: {}
  Users: {}

  # corners and borders(borders - corners) of current blocks
  corners: {}
  borders: {}

  # 0: screenX
  # 1: screenY
  # 2: stat
  # 3: todo
  Grid: []

  currentPlayer: {}

  turn: 0
  step: 0

  initUser: (n) ->
    SQ.Users = new Users(n)

  loadResource: (onFinishLoading) ->
    tileAtlas = ["public/images.json"]
    loader = new PIXI.AssetLoader(tileAtlas)

    loader.onComplete = onFinishLoading
    loader.load()

  initContainer: () ->
    SQ.board = @board = new PIXI.DisplayObjectContainer()
    stage.addChild(@board)
    document.body.appendChild(renderer.view)

  initHumanBlock: (blocks, texure) ->
    @humanBlocks = new Blocks blocks, 'human', texure

  initAIBlock: (blocks, texure) ->
    @AIBlocks = new Blocks blocks, 'ai', texure

  initGameControl: () ->
    self = this

    restart = @restart = new PIXI.Text('RESTART')
    restart.interactive = true
    restart.buttonMode = true

    restart.position.x = MARGIN_L + WIDTH * DIM
    restart.position.y = MARGIN_T + WIDTH * DIM
    SQ.board.addChild(restart)
    restart.mousedown = restart.touchstart = () ->
      $('canvas').remove()
      window.stage = null
      window.stage = new PIXI.Stage(0xffffff)
      window.renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight)
      SQ.board = null
      @board = null
      SQ.playground = new Playground()

    # multiple bind
    # $('.pause').click () ->
    #   isPaused = !isPaused
    #   window.alert('game paused: ' + isPaused)
    #   unless isPaused
    #     requestAnimFrame(animate)

    # $('.restart').click () ->
    #   $('canvas').remove()
    #   window.stage = null
    #   window.stage = new PIXI.Stage(0xffffff)
    #   window.renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight)
    #   SQ.board = null
    #   @board = null
    #   SQ.playground = new Playground()

    # $('#move').click () ->
    #   n = $('.block-n').val()
    #   x = parseInt $('.dx').val()
    #   y = parseInt $('.dy').val()
    #   self.placeN(n, x, y)

  initFBSync: () ->
    window.FBref = new Firebase("https://squares-game.firebaseio.com/");

    # TODO manage game room session
    ref = FBref.child('game')
    ref.on 'value', (snapshot) =>
      val = snapshot.val()
      console.log(val)
      if val is null
        FBref.set
          game: {}
        @createNewGame()

    ref.on 'child_added', (snapshot) =>
      newStep = snapshot.val()
      console.log(newStep);
      # @execStep(newStep);

  createNewGame: () ->
    ref = FBref.child('game')

    ref.on 'child_added', (snapshot) ->
      console.log(snapshot.val())
    ref.push
      gameSession: 'session-' + Date.now()

  execStep: (step) =>
    pos = JSON.parse step.pos
    if step.player != @currentPlayer.id
      @placeN(step.blockOrder, pos[0], pos[1])

  getCoord: (pos) ->
    return [MARGIN_L + pos[0] * WIDTH, MARGIN_T + pos[1] * WIDTH]

  initPlayerState: () ->
    @tile_player = tile_player = PIXI.Sprite.fromFrame(0)
    tile_player.position.x = MARGIN_L + WIDTH * 13 + 40
    tile_player.position.y = MARGIN_T
    tile_player.scale.x = .3
    tile_player.scale.y = .3
    SQ.board.addChild(tile_player)

    @tile_ai = tile_ai = PIXI.Sprite.fromFrame(1)
    tile_ai.position.x = MARGIN_L - 80
    tile_ai.position.y = MARGIN_T
    tile_ai.scale.x = .3
    tile_ai.scale.y = .3
    tile_ai.alpha = 0.5
    SQ.board.addChild(tile_ai)

  player_on: () ->
    @tile_ai.alpha = 0.5
    @tile_player.alpha = 1

  ai_on: () ->
    @tile_ai.alpha = 1
    @tile_player.alpha = 0.5

  initGrid: () ->
    self = this
    self.Grid = []
    _drawGrid_block = (x, y) ->
      tile = PIXI.Sprite.fromFrame(4)
      tile.interactive = true
      tile.buttonMode = true
      tile.isSelected = false
      tile.theVal = [x,y]
      tile.position.x = x
      tile.position.y = y
      # tile.scale.x = .3
      # tile.scale.y = .3
      tile.anchor.x = 0.5
      tile.anchor.y = 0.5
      tile.tint = 0xffffff
      tile.alpha = 0.5
      self.board.addChild(tile)

      tile.mousedown = tile.touchstart = (data) ->
        # console.log data

      tile.mouseup = tile.mouseupoutside = tile.touchend = tile.touchendoutside = (data) ->
        # console.log data

      tile.mousemove = tile.touchmove = (data) ->
        # console.log data

    drawRule = () ->
      for i in [0..DIM-1]
        text = new PIXI.Text(i)
        text.position.x = MARGIN_L + i * WIDTH - 10
        text.position.y = MARGIN_T - WIDTH - 10
        self.board.addChild(text)
      for j in [0..DIM-1]
        text = new PIXI.Text(j)
        text.position.x = MARGIN_L - WIDTH - 10
        text.position.y = MARGIN_T + j * WIDTH - 10
        self.board.addChild(text)

    drawGrid = () ->
      for i in [0..DIM-1]
        gy = []
        for j in [0..DIM-1]
          gy.push self.getCoord([i, j]).concat([-1, null]);
        self.Grid.push gy

      self.Grid.map (i) ->
        i.map (j) ->
          _drawGrid_block(j[0], j[1])
          return j
        return i

    self.Block_el.red = PIXI.Sprite.fromFrame(0)
    console.log(@Block_el)
    # drawRule()
    drawGrid()
    SQ.Grid = self.Grid

  drawBackground: () ->
    bg = new PIXI.Sprite(PIXI.Texture.Draw (canvas) ->
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
      context = canvas.getContext('2d')
      context.rect(0, 0, canvas.width, canvas.height)

      grd = context.createLinearGradient(0, 0, canvas.width, canvas.height)
      grd.addColorStop(0, '#6EB8D0')
      grd.addColorStop(1, '#D78C93')
      context.fillStyle = grd
      context.fill()
    )

    stage.addChild(bg)

  drawBlockPanel: (blocks) ->
    self = this
    SQ.panel = blockPanel = new PIXI.DisplayObjectContainer()
    blockPanel.position.x = window.innerWidth - 200
    blockPanel.position.y = 0
    blockPanel.width = 32
    blockPanel.height = 700
    blockPanel.interactive = true

    for k, v of @humanBlocks._blocks
      blockPanel.addChild(v)

    stage.addChild(blockPanel)

  getStat: (x, y) =>
    return 0 if x < 0 or y < 0
    return @Grid[y][x][2]

  getBlockStat: (x, y) =>
    return null if x < 0 or y < 0 or typeof @Grid[y][x][2] isnt 'number'
    if @Grid[y][x][2] is -1
      return null
    else
      return @Grid[y][x][2]

  getStatTable: () ->
    return @Grid.map (row) ->
      return row.map (b) ->
        return b[2]

  setOccupied: (x, y, state) =>
    if @Grid[y][x][2] > -1
      return
    if typeof state is 'number'
      @Grid[y][x][2] = state
      return

    @Grid[y][x][2] = [] unless @Grid[y][x][2] > -1
    @Grid[y][x][2].push state

  withinGrid: (pos) ->
    if pos[0] > -1 and pos[0] < DIM and pos[1] > -1 and pos[1] < DIM
      return true
    else
      return false

  _addCorners: (block) ->
    userId = SQ.Users.current().id
    for c in block.corners
      pos = [block.gx + c[0], block.gy + c[1]]
      if @withinGrid(pos)
        @corners[pos.toString()] = userId + '.c'
        # @Grid[block.gy + c[1]][block.gx + c[0]][2] = userId + '.c';
    console.log(@corners)

  # get array of corners of current user
  getCorners: () ->
    res = []
    userId = SQ.Users.current().id

    for k, v of @corners
      if v[userId] is true
        res.push k.split(',').map (n) ->
          return parseInt n

    return res

  blockPlaced: (pos) ->
    return @getStat(pos[0], pos[1]) > -1

  # add corners and return corner count of current user
  addCorners: (block, cpos) ->
    userId = SQ.Users.current().id

    for c in block.corners
      # corners coord has been adjusted
      pos = [c[0] + cpos[0], c[1] + cpos[1]]
      continue if not @withinGrid(pos) or @blockPlaced(pos)

      # border's priority is higher than corner's
      if @withinGrid(pos) and (not @borders[pos.toString()] or not @borders[pos.toString()][userId])
        @setOccupied(pos[0], pos[1], userId + '.c')
        if @corners[pos.toString()]
          @corners[pos.toString()][userId] = true
        else
          @corners[pos.toString()] = {}
          @corners[pos.toString()][userId] = true

    # console.log @corners
    # for k, v in @corners
    #   if Object.keys(v).length is 0
    #     delete @corners[k]
    #   else if @borders[k] and @borders[k][userId] is true

    _corners = {}
    for k, v of @corners
      if v[userId] is true
        _corners[k] = v

    Object.keys(_corners).length

  removeCorners: (block, cpos) ->
    userId = SQ.Users.current().id

    for c in block.corners
      # corners coord has been adjusted
      pos = [c[0] + cpos[0], c[1] + cpos[1]]
      if @withinGrid(pos)
        @setOccupied(pos[0], pos[1], userId + '.c')
        if @corners[pos.toString()]
          @corners[pos.toString()][userId] = false
        else
          @corners[pos.toString()] = {}
          @corners[pos.toString()][userId] = false

  addBorders: (block, cpos) ->
    userId = SQ.Users.current().id
    for b in block.borders
      pos = [b[0] + cpos[0], b[1] + cpos[1]]
      if @withinGrid(pos)
        @setOccupied(pos[0], pos[1], userId + '.b')
        if @borders[pos.toString()]
          @borders[pos.toString()][userId] = true
          @corners[pos.toString()][userId] = false if @corners[pos.toString()]
        else
          @borders[pos.toString()] = {}
          @borders[pos.toString()][userId] = true
          @corners[pos.toString()][userId] = false if @corners[pos.toString()]

    console.log(@borders)

  isOnCorners: (pos) ->
    userId = SQ.Users.current().id
    mark = @corners[pos.toString()]
    if mark and mark[userId] is true
      return true
    else
      return false

  isOnBorders: (pos) ->
    userId = SQ.Users.current().id
    mark = @borders[pos.toString()]
    if mark and mark[userId] is true
      return true
    else
      return false

  # TODO: add corner check to placable
  placable: (block, coord) =>
    flag = false
    # flag = false unless @corners[[x, y].toString()]
    x = if coord then coord[0] else block.gx
    y = if coord then coord[1] else block.gy
    # console.log '=== placable start ==='
    # inside grid
    for pos in block.coord
      _x = x + pos[0]
      _y = y + pos[1]
      if _x > DIM-1 or _x < 0 or _y > DIM-1 or _y < 0
        # console.log 'fail - out of grid bound'
        return false


    # test first step should be at the corner
    if @turn is 0
      validFistStep = false
      for pos in block.coord
        _x = x + pos[0]
        _y = y + pos[1]
        if (_x is DIM-1 and _y is DIM-1) or (_x is 0 and _y is 0)
          # console.log 'pass - valid first step'
          validFistStep = true
          break
      return unless validFistStep

    # at least one block in current corners
    block.coord.map (pos) =>
      if @isOnCorners([x + pos[0], y + pos[1]])
        # console.log 'pass - at least 1 corner hit'
        flag = true

    # none in border blocks.
    block.coord.map (pos) =>
      if @isOnBorders([x + pos[0], y + pos[1]])
        # console.log 'fail - border taken'
        flag = false

    # first turn
    flag = true if @turn is 0

    # should be empty
    block.coord.map (rp) =>
      if @occupied(x + rp[0], y + rp[1])
        # console.log 'fail - grid taken'
        flag = false

    # console.log '=== placable end ==='
    return flag

  # occupied by either user
  occupied: (x, y) ->
    SQ.playground.getStat(x, y) > -1

  placeN: (type, index, pos) =>
    x = parseInt pos[0]
    y = parseInt pos[1]
    if type is 'ai'
      block = @AIBlocks.getBlock(index)
    else if type is 'human'
      block = @humanBlocks.getBlock(index)
    else
      throw 'placeN type error'

    return if block is null

    block.scale = {x:1, y:1}
    if block.put
      @unplace(block)
    else
      SQ.board.addChild(block)

    if type is 'ai'
      @place(block, pos, true)
      @finishPlace(block)
    else
      if @placable(block, pos)
        @place(block, pos, true)
        @finishPlace(block)
      else
        # @placeBack(block)
    @udpateInfoBoard()


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

  writeStats: (block) ->
    userId = parseInt SQ.Users.current().id

    block.coord.map (rp) =>
      @setOccupied(block.gx + rp[0], block.gy + rp[1], userId)
      @corners[[block.gx + rp[0], block.gy + rp[1]].toString()] = {}
      @borders[[block.gx + rp[0], block.gy + rp[1]].toString()] = {}

    @addCorners(block, [block.gx, block.gy])
    @addBorders(block, [block.gx, block.gy])

  finishPlace: (block, fromSync) =>
    # mixpanel.track("place block");
    analytics.track('events', {
      step: 'place-block'
    });
    block.finish = true
    # relative position
    @writeStats(block)

    if block.type is 'human'
      @removeControlPanel(block)
      @removeEvent(block)

    @udpateInfoBoard()
    # unless fromSync
    #   @pushPlace(block, x, y)

    @step += 1
    if SQ.Users.finishTurn
      @turn += 1
      SQ.Users.finishTurn = false

    # @drawCorners()
    SQ.Users.nextTurn()

  drawCorners: ->
    @cornerLayer = @cornerLayer || []
    for t in @cornerLayer
      @board.removeChild(t)
    @cornerLayer = []

    for k,v of @corners
      pos = k.split(',').map((e)-> return parseInt(e));
      if v[0] or v[1]
        _text = if v[0] then '0' else '1'
        text = new PIXI.Text(_text)
        text.position.x = MARGIN_L + pos[0] * WIDTH - 10
        text.position.y = MARGIN_T + pos[1] * WIDTH - 10
        @cornerLayer.push text
        @board.addChild(text)

  removeControlPanel: (block) ->
    block.removeChild(block.fliph)
    block.removeChild(block.flipv)
    block.removeChild(block.confirm)
    block.removeChild(block.cancel)
    block.removeChild(block.rotatecw)
    block.removeChild(block.rotateacw)

  removeEvent: (block) ->
    block.mouseover = block.mouseout = null

    block.mousedown = block.touchstart = null

    block.mouseup = block.mouseupoutside = block.touchend = block.touchendoutside = null

    block.mousemove = block.touchmove = null


  pushPlace: (block, x, y) ->
    ref = FBref.child('game')
    data =
      player: @currentPlayer.id
      grid: JSON.stringify @Grid
      step: @step
      blockOrder: block.order
      pos: JSON.stringify [x, y]

    ref.push data

  unplace: (block) ->
    block.put = false
    x = block.gx
    y = block.gy

    block.coord.map (rp) =>
      @setOccupied(x + rp[0], y + rp[1], -1)

  placeBack: (block) ->
    block.position.x = block.ox
    block.position.y = block.oy
    block.put = false

    block.removeChild(block.fliph)
    block.fliph = null
    block.removeChild(block.flipv)
    block.flipv = null
    block.removeChild(block.confirm)
    block.confirm = null
    block.removeChild(block.cancel)
    block.cancel = null
    block.removeChild(block.rotatecw)
    block.rotatecw = null
    block.removeChild(block.rotateacw)
    block.rotateacw = null

    SQ.board.removeChild(block)
    block.scale = {x:.5, y:.5}
    SQ.panel.addChild(block)

  udpateInfoBoard: () ->
    $('.info-board').html("")
    @Grid.map (e) ->
      stat = e.map (_e) ->
        return _e[2]
      html = ''
      stat.map (e) ->
        html += '<div class="dd">' + e + '</div>'
      $('.info-board').append('<div class="row">' + html + '</div>')

  next: =>
    if @Blocks.hasBlockLeft()
      @currentUser = @Users.nextUser()
      @setUserUI(user)

  UnitTest: () ->
    # grid
    @Grid.map (e, i) ->
      gy = e[0];
      console.assert(gy[0] is (MARGIN_L + WIDTH * i), 'grid init')
      console.assert(gy[1] is MARGIN_T, 'grid init')
      console.assert(gy[3] is null, 'grid init')

  setUserUI: (user) ->
    s = user.id + ' is playing'
    $('#user').html(s)

  placeBlock: (block) ->
    # drag to valid position


  render: (block) ->


  takenInit: ->
    i = @Users.num
    taken = {}
    while i--
      taken[i] = 0
      taken

  takenBy: (takens) ->
    for user, num in takens
      if num > max
        max = num
    _.filter [num for user, num of takens], (x)->x is max

  complete: ( score, takens, type ) ->
    for user in takens
      user.scored[type] += score
    UI.removeFollowers(takens)
