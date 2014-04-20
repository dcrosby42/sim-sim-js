class ClientMessageFactory
  turnFinished: (turnNumber, checksum) ->
    {
      type: 'ClientMsg::TurnFinished'
      turnNumber: turnNumber
      checksum: checksum
    }

  gamestate: (forPlayerId, protoTurn, simState, worldState) ->
    {
      type: 'ClientMsg::Gamestate'
      forPlayerId: forPlayerId
      protoTurn: protoTurn
      simState: simState
      worldState: worldState
    }

  event: (data) ->
    {
      type: 'ClientMsg::Event'
      data: data
    }

module.exports = ClientMessageFactory
