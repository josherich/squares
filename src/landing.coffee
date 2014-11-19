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

Landing =
  map: {}

  init: (start) ->
    @drawBackground()
    @initContainer()
    # @initControl(start)
    @loadResource () =>
      @initAna()
      Grid.getCurrent()
      @initGrid(start)
      requestAnimFrame(animate)

  initAna: () ->
    analytics.identify(Date.now(), {
      name: 'Josherich' + Date.now(),
      email: 'josherichchen@gmail.com'
    });
    analytics.track('events', {
      step: 'landing'
    });

  initContainer: () ->
    # SQ.board = @board = new PIXI.DisplayObjectContainer()
    # stage.addChild(@board)
    document.body.appendChild(renderer.view)

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

  # initControl: (start) ->
  #   enter = new PIXI.Text("PLAY")
  #   enter.interactive = true
  #   enter.position.x = window.innerWidth - 100
  #   enter.position.y = window.innerHeight - 100
  #   enter.mousedown = enter.touchstart = (data) ->
  #     start()
  #   stage.addChild enter

  loadResource: (onFinishLoading) ->
    tileAtlas = ["public/images.json"]
    loader = new PIXI.AssetLoader(tileAtlas)

    loader.onComplete = onFinishLoading
    loader.load()

  randomBlock: () ->
    arr = {}
    n = Math.floor(Math.random() * 10) + 40
    for i in [0..n]
      arr[[Math.floor(Math.random() * 20) + ',' + Math.floor(Math.random() * 20)]] = true
    arr

  initGrid: (start) ->
    self = this
    dim = 21
    randomBlock = this.randomBlock()

    getCoord = (pos) ->
      return [MARGIN_L + pos[0] * WIDTH, MARGIN_T + pos[1] * WIDTH]
    draw = (x, y, _x, _y) ->
      if _x is 10 and _y is 10
        tile = PIXI.Sprite.fromFrame(6)
        tile.taken = 1
        tile.mousedown = tile.touchstart = (data) ->
          Animation.play(tile, 'explode')
          setTimeout () ->
            start()
            tile.mousedown = tile.touchstart = null
            stage.mousemove = null
          , 2000
      else if randomBlock[_y + ',' + _x]
        tile = PIXI.Sprite.fromFrame(11)
        tile.taken = 1
      else
        tile = PIXI.Sprite.fromFrame(4)
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

      if _x is 10 and _x is _y
        tile.alpha = 1
        this.tint = 0xff00ff
      self.map[_y + ',' + _x] = tile
      stage.addChild(tile)

    Grid.init(dim, draw, getCoord, randomBlock)