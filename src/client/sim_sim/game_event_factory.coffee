class GameEventFactory
  disconnected: ->
    {
      type: 'GameEvent::Disconnected'
    }

  gamestateRequest: (f) ->
    {
      type: 'GameEvent::GamestateRequest'
      gamestateClosure: f
    }

  startGame: (ourId, turnPeriod, currentTurn, simState, worldState) ->
    {
      type: 'GameEvent::StartGame'
      ourId: ourId
      turnPeriod: turnPeriod
      currentTurn: currentTurn
      simState: simState
      worldState: worldState
    }

  turnComplete: (turnNumber, events, checksumClosure) ->
    {
      type: 'GameEvent::TurnComplete'
      turnNumber: turnNumber
      events: events
      checksumClosure: checksumClosure
    }

module.exports = GameEventFactory
