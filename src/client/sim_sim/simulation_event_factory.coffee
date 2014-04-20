class SimulationEventFactory
  event: (playerId, data) ->
    {
      type: 'SimulationEvent::Event'
      playerId: playerId
      data: data
    }

  playerJoined: (playerId) ->
    {
      type: 'SimulationEvent::PlayerJoined'
      playerId: playerId
    }

  playerLeft: (playerId) ->
    {
      type: 'SimulationEvent::PlayerLeft'
      playerId: playerId
    }

module.exports = SimulationEventFactory
