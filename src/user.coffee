class Users
  finishTurn: false
  _users: []
  userIndex: 0

  constructor: (n) ->
    if n is 2
      me = new User(this, 'human', 0)
      you = new User(this, 'ai', 1)
      @_users.push(me)
      @_users.push(you)

  current: () ->
    @_users[@userIndex]

  nextUser: () ->
    @userIndex = SQ.playground.step % @_users.length

  nextTurn: () ->
    @nextUser()
    SQ.Mediator.publish 'nextOne', @current()
    @setUserUI()

  scoring: (type, id, score) ->
    console.log @_users
    @_users[id - 1][type] += score

  getScore: (id) ->
    return @_users[id - 1]['road'] + @_users[id - 1]['castle']

  setUserUI: () ->

class User
  id: 0
  type: null
  score: 0
  parent: {}

  constructor: (parent, type, id) ->
    @parent = parent
    @type = type
    @id = id
    SQ.Mediator.subscribe 'nextOne', (user) =>
      @think()

  think: () ->
    if @type is 'ai' and @parent.userIndex is @id
      SQ.AI.compute()
    # wait confirm if it's human

  isHuman: () ->
    return @type is 'human'

