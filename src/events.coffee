Mediator =
  handlerMap: {}

  init: ->
    window.addEventListener('message', this.processMessage, false)

  publish: (id, params) ->
    msg =
      id: id
      params: params
    window.postMessage msg, '*'

  subscribe: (id, handler) ->
    if Object.keys(@handlerMap).length is 0
      @init()
    handlers = @handlerMap[id]
    if handlers is undefined
      handlers = []
    handlers.push handler
    @handlerMap[id] = handlers

  unsubscribe: (id, handler) ->
    handlers = @handlerMap[id]
    return if handlers is undefined

    for h, i in handlers
      if h is handler
        handlers.slice(i, i+1)

  processMessage: (event) ->
    if event.data isnt null and event.data['id'] isnt null
      handlers = SQ.Mediator.handlerMap[event.data['id']]
      if handlers isnt null
        for h in handlers
          h(event.data['params'])
