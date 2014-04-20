class ServerMessageFactory
  event: (id, data) ->
    {
      type: 'ServerMessage::Event'
      sourcePlayerId: id
      data: data
    }

  playerJoined: (id) ->
    {
      type: 'ServerMessage::PlayerJoined'
      playerId: id
    }

  playerLeft: (id) ->
    {
      type: 'ServerMessage::PlayerLeft'
      playerId: id
    }

  turnComplete: (currentTurn) ->
    {
      type: 'ServerMessage::TurnComplete'
      turnNumber: currentTurn
    }

  idAssigned: (id) ->
    {
      type: 'ServerMessage::IdAssigned'
      ourId: id
    }

  gamestateRequest: (id) ->
    {
      type: 'ServerMessage::GamestateRequest'
      forPlayerId: id
    }

  startGame: (forPlayerId, turnPeriod, currentTurn, protoTurn, simState, worldState) ->
    {
      type: 'ServerMessage::StartGame'
      yourId: forPlayerId
      turnPeriod: turnPeriod
      currentTurn: currentTurn
      protoTurn: protoTurn
      simState: simState
      worldState: worldState
    }

module.exports = ServerMessageFactory
