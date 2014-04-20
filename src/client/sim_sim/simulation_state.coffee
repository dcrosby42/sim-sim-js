fixFloat = require('./fix_float.coffee')

class SimulationState
  constructor: (@timePerTurn,
                @stepsPerTurn,
                @step) ->
    @timePerStep = fixFloat(@timePerTurn / @stepsPerTurn)

module.exports = SimulationState
