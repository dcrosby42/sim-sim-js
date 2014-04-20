SimulationState = require './simulation_state.coffee'

class SimulationStateFactory
  constructor: (@defaults) ->

  createSimulationState: ->
    new SimulationState(
      @defaults.timePerTurn
      @defaults.stepsPerTurn
      0 # step
    )

module.exports = SimulationStateFactory
