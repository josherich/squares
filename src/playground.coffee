assert = (test, name) ->
  name = name || 'default assert'
  console.assert(test, name)

isPaused = false
animate = ->
  update() if isPaused
  renderer.render(stage)
  requestAnimFrame(animate)

MARGIN = 74
WIDTH = 32

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
    @initUser(2)
    @initContainer()
    @initGameControl()
    # @initFBSync()
    @loadResource () =>
      @initGrid()
      @initBlock BLOCK, @Block_el
      @drawBlockPanel(BLOCK)
      # @initUserUI()
      @UnitTest()
      requestAnimFrame(animate)

  Block_el: {}
  Blocks: {}
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

  initGameControl: () ->
    self = this
    $('.pause').click () ->
      isPaused = !isPaused
      window.alert('game paused: ' + isPaused)
      unless isPaused
        requestAnimFrame(animate)

    $('#move').click () ->
      n = $('.block-n').val()
      x = parseInt $('.dx').val()
      y = parseInt $('.dy').val()
      self.placeN(n, x, y)

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

  getCoord: (ix, iy) ->
    margin = 74
    width = 32
    return [margin + ix * width, margin + iy * width]

  initGrid: () ->
    self = this
    _drawGrid_block = (x, y) ->
      tile = PIXI.Sprite.fromFrame(0)
      tile.interactive = true
      tile.buttonMode = true
      tile.isSelected = false
      tile.theVal = [x,y]
      tile.position.x = x
      tile.position.y = y
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

    drawGrid = (Grid) ->
      for i in [0..19]
        gy = []
        for j in [0..19]
          gy.push self.getCoord(i, j).concat([0, null]);
        self.Grid.push gy

      self.Grid.map (i) ->
        i.map (j) ->
          _drawGrid_block(j[0], j[1])
          return j
        return i
      console.log stage.children

    self.Block_el.red = PIXI.Sprite.fromFrame(0)
    console.log(@Block_el)
    drawGrid()
    SQ.Grid = self.Grid

  drawBlockPanel: (blocks) ->
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

    blocks.map (b, bi) =>
      block = SQ.playground.Blocks.drawBlock(b, bi, 0)
      blockPanel.addChild(block)

    stage.addChild(blockPanel)

  getStat: (x, y) =>
    return 0 if x < 0 or y < 0
    return @Grid[y][x][2]

  getStatTable: () ->
    return @Grid.map (row) ->
      return row.map (b) ->
        return b[2]

  setOccupied: (x, y, state) =>
    @Grid[y][x][2] = state

  withinGrid: (pos) ->
    if pos[0] > -1 and pos[0] < 20 and pos[1] > -1 and pos[1] < 20
      return true
    else
      return false

  addCorners: (block) ->
    userId = SQ.Users.current().id
    for c in block.corners
      pos = [block.gx + c[0], block.gy + c[1]]
      if @withinGrid(pos)
        @corners[pos.toString()] = userId + '.c'
        # @Grid[block.gy + c[1]][block.gx + c[0]][2] = userId + '.c';
    console.log(@corners)

  addBorders: (block) ->
    userId = SQ.Users.current().id
    for b in block.borders
      pos = [block.gx + b[0], block.gy + b[1]]
      if @withinGrid(pos)
        @borders[pos.toString()] = userId + '.b'
        # @Grid[block.gy + b[1]][block.gx + b[0]][2] = userId + '.b';
    console.log(@borders)

  isOnCorners: (pos) ->
    userId = SQ.Users.current().id
    mark = @corners[pos.toString()]
    if mark and mark.split('.')[0] is userId.toString()
      return true
    else
      return false

  isOnBorders: (pos) ->
    userId = SQ.Users.current().id
    mark = @borders[pos.toString()]
    if mark and mark.split('.')[0] is userId.toString()
      return true
    else
      return false

  # TODO: add corner check to placable
  placable: (block, x, y) =>
    flag = false
    # flag = false unless @corners[[x, y].toString()]

    # inside grid
    for pos in block.coord
      _x = x + pos[0]
      _y = y + pos[1]
      if _x > 19 or x < 0 or _y > 19 or _y < 0
        return false

    # test first step should be at the corner
    if @step is 0
      validFistStep = false
      for pos in block.coord
        _x = x + pos[0]
        _y = y + pos[1]
        validFistStep = true if _x is 19 and _y is 19
      return unless validFistStep

    # at least one block in current corners
    block.coord.map (pos) =>
      flag = true if @isOnCorners([x + pos[0], y + pos[1]])

    # none in border blocks.
    block.coord.map (pos) =>
      flag = false if @isOnBorders([x + pos[0], y + pos[1]])

    # first block
    flag = true if Object.keys(@corners).length is 0

    # should be empty
    block.coord.map (rp) =>
      flag = false if @occupied(x + rp[0], y + rp[1])
    return flag

  # occupied by either user
  occupied: (x, y) ->
    SQ.playground.getStat(x, y) is 1

  placeN: (n, x, y) =>
    block = @Blocks.getBlock(n)
    return if block is null
    block.scale = {x:1, y:1}
    if block.put
      @unplace(block)
    else
      SQ.board.addChild(block)

    if @placable(block, x, y)
      @place(block, x, y, true)
    else
      @placeBack(block)
    @udpateInfoBoard()


  place: (block, x, y, fromSync) =>
    # ix = Math.floor((x - 74) / 32)
    # iy = Math.floor((y - 74) / 32)
    block.put = true
    pos = @getCoord(x, y)

    block.position =
      x: pos[0] - WIDTH / 2
      y: pos[1] - WIDTH / 2

    block.gx = x
    block.gy = y

  finishPlace: (block, fromSync) =>
    block.finish = true
    # relative position
    block.coord.map (rp) =>
      @setOccupied(block.gx + rp[0], block.gy + rp[1], 1)

    @addCorners(block)
    @addBorders(block)

    @udpateInfoBoard()
    # unless fromSync
    #   @pushPlace(block, x, y)

    @step += 1
    if SQ.Users.turnFinished
      @turn += 1

    SQ.Users.nextTurn()

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
      @setOccupied(x + rp[0], y + rp[1], 0)

  placeBack: (block) ->
    block.position.x = block.position.ox
    block.position.y = block.position.oy
    SQ.board.removeChild(block)
    SQ.panel.addChild(block)
    block.scale = {x:.5, y:.5}

  udpateInfoBoard: () ->
    $('.info-board').html("")
    @Grid.map (e) ->
      stat = e.map (_e) ->
        return _e[2]
      $('.info-board').append($('<p>' + stat.toString() + '</p>'))

  initBlock: (blocks, texure) ->
    @Blocks = new Blocks blocks, @next, @Users, this

    # @currentUser = @Users.nextUser()
    # @setUserUI()

  next: =>
    if @Blocks.hasBlockLeft()
      @currentUser = @Users.nextUser()
      @setUserUI(user)

  UnitTest: () ->
    # grid
    @Grid.map (e, i) ->
      gy = e[0];
      console.assert(gy[0] is (74 + 32 * i), 'grid init')
      console.assert(gy[1] is 74, 'grid init')
      console.assert(gy[2] is 0, 'grid init')
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
