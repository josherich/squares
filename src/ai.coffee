class AI
  constructor: (playground) ->

  # 2 / 4 person
  mode: 'defaultMode'

  expertRules: []

  strategyMode: []

  updateState: ->


  computeState: ->


  computeValue: ->

  # decide the first 4 or 5 steps before reaching anyone
  computeStartupSteps: ->


  computeSteps: ->


  computeExpertRules: ->


  switchStrategyMode: ->


  compute: () ->
    console.log("I'm thinking, bitch!")
    @makeMove()
    SQ.playground.step += 1
    SQ.playground.turn += 1
    SQ.Users.nextTurn()

  makeMove: () ->
    console.log("I'm done, bitch!")
