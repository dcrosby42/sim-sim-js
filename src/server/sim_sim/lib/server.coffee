
class Server
  constructor: (@adapter, @turnManager, @serverMessageFactory, @syncManager) ->
    @_debugOn = false

    m = @serverMessageFactory
    @turnManager.on 'turn_ended', (currentTurn) =>
      @_debug "Turn #{currentTurn} ended"
      @_broadcast m.turnComplete(currentTurn)
      @syncManager.turnEnded(currentTurn)

    @adapter.on 'Network::PeerConnected', (id) =>
      @_debug "Network::PeerConnected",id
      @_send id, m.idAssigned(id)
      stateProviderId = @_selectOtherPlayer(id)
      @_debug "  (selected player #{stateProviderId} to provide state to newcomer #{id})"
      
      if @adapter.clientCount() == 1
        # First player on the scene -> start counting turns
        @turnManager.start()

      # Ask someone to send the state to the new player
      @_send stateProviderId, m.gamestateRequest(id)
      @_broadcast m.playerJoined(id)

    @adapter.on 'Network::PeerDisconnected', (id) =>
      @_debug "Network::PeerDisconnected #{id}"
      if @adapter.clientCount() == 0
        @turnManager.stop()
        @turnManager.reset()
      @_broadcast m.playerLeft(id)

    @adapter.on 'Network::PeerPacket', (id, data) =>
      @_debug 'Network::PeerPacket', id, data
      msg = @_unpackClientMessage(data)
      switch msg.type
        when 'ClientMsg::Event'
          @_broadcast m.event(id, msg.data)
        when 'ClientMsg::Gamestate'
          @_send msg.forPlayerId, m.startGame(msg.forPlayerId, @turnManager.period, @turnManager.current, msg.protoTurn, msg.simState, msg.worldState)

        when 'ClientMsg::TurnFinished'
          @syncManager.gotChecksum(
            playerId: id
            turnNumber: msg.turnNumber
            checksum: msg.checksum
            clientIds: @adapter.clientIds.slice(0)
            defaultProviderId: @adapter.clientIds[0]
            resync: (fromId,toId) =>
              console.log "SENDING @_send #{fromId}, m.gamestateRequest(#{toId})"
              @_send fromId, m.gamestateRequest(toId)
          )


  _send: (id, msg) ->
    @adapter.send id, @_packServerMessage(msg)

  _broadcast: (msg) ->

    @adapter.broadcast @_packServerMessage(msg)

  _unpackClientMessage: (msg) ->
    msg

  _packServerMessage: (msg) ->
    msg

  _selectOtherPlayer: (id) ->
    return id if @adapter.clientCount() == 1 # There's only one player

    if @adapter.clientIds[0] != id
      return @adapter.clientIds[0]
    else
      return @adapter.clientids[1]

  _debug: (args...) ->
    console.log ">>> [Server]", args... if @_debugOn

module.exports = Server
