class Users
  constructor: (@num) ->
    @_users.push(new User(i)) for i in [1..@num]

  _users: []

  nextUser: ->
    @num = @_users.length if @num is 0
    console.log @num
    return @_users[--@num]

  scoring: (type, id, score) ->
    console.log @_users
    @_users[id - 1][type] += score

  getScore: (id) ->
    return @_users[id - 1]['road'] + @_users[id - 1]['castle']

class User
  constructor: (@id) ->

  id: 0
  score: 0

  setUI: ->
    selector = 'player' + @id
    document.getElementById(selector).innerHTML = 'player ' + @id + ' ongoing'

  getBlock: (block)->
    @placeBlock(block)