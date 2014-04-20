WorldBase = require '../../../client/simult_sim/world_base'

class TestWorld extends WorldBase
  constructor: (data) ->
    @someProperty = data.someProperty
    @stepCalls = []

  isTestWorld: -> true

  step: (dt) ->
    @stepCalls.push dt


module.exports = TestWorld
