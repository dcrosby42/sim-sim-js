SimulationState = require './simulation_state.coffee'

class SimulationStateSerializer
  constructor: (@simulationStateFactory) ->

  packSimulationState: (simState) ->
    {
      timePerTurn: simState.timePerTurn
      stepsPerTurn: simState.stepsPerTurn
      step: simState.step
    }

  unpackSimulationState: (data) ->
    new SimulationState(
      data.timePerTurn
      data.stepsPerTurn
      data.step
    )

module.exports = SimulationStateSerializer
