
class TurnCalculator

  advanceTurn: (simState,world) ->
    @stepUntil simState, world, simState.stepsPerTurn
    simState.step = 0

  stepUntilTurnTime: (simState, world, turnTime) ->
    shouldBeStep = Math.round(turnTime / simState.timePerStep)
    @stepUntil simState, world, shouldBeStep

  stepUntil: (simState,world,n) ->
    limit = simState.stepsPerTurn
    limit = n if n < limit
    while simState.step < limit
      simState.step += 1
      world.step simState.timePerStep

module.exports = TurnCalculator
