
class Server
  constructor: (@adapter, @turnManager, @serverMessageFactory, @syncManager, @loggingConfig) ->
    m = @serverMessageFactory
    @turnManager.on 'turn_ended', (currentTurn) =>
      @_broadcast m.turnComplete(currentTurn)
      @syncManager.turnEnded(currentTurn)

    @adapter.on 'Network::PeerConnected', (id) =>
      @_logIncoming "Network::PeerConnected",id
      @_send id, m.idAssigned(id)
      stateProviderId = @_selectOtherPlayer(id)
      @_logDebug "Selected player #{stateProviderId} to SEND STATE TO newcomer #{id})"
      
      if @adapter.clientCount() == 1
        # First player on the scene -> start counting turns
        @turnManager.start()

      # Ask someone to send the state to the new player
      @_send stateProviderId, m.gamestateRequest(id)
      @_broadcast m.playerJoined(id)

    @adapter.on 'Network::PeerDisconnected', (id) =>
      @_logIncoming "Network::PeerDisconnected", id
      if @adapter.clientCount() == 0
        @turnManager.stop()
        @turnManager.reset()
      @_broadcast m.playerLeft(id)

    @adapter.on 'Network::PeerPacket', (id, data) =>
      msg = @_unpackClientMessage(data)
      switch msg.type
        when 'ClientMsg::Event'
          @_logIncoming 'ClientMsg::Event', msg.data
          @_broadcast m.event(id, msg.data)
        when 'ClientMsg::Gamestate'
          @_logIncoming 'ClientMsg::Gamestate', msg.forPlayerId
          @_send msg.forPlayerId, m.startGame(msg.forPlayerId, @turnManager.period, @turnManager.current, msg.protoTurn, msg.simState, msg.worldState)

        when 'ClientMsg::TurnFinished'
          @_logIncoming 'ClientMsg::TurnFinished', msg.turnNumber, msg.checksum
          @syncManager.gotChecksum(
            playerId: id
            turnNumber: msg.turnNumber
            checksum: msg.checksum
            clientIds: @adapter.clientIds.slice(0)
            defaultProviderId: @adapter.clientIds[0]
            resync: (fromId,toId) =>
              @_logDebug "SENDING STATE from: #{fromId} -> #{toId}"
              @_send fromId, m.gamestateRequest(toId)
          )


  _send: (id, msg) ->
    @_logOutgoing msg.type, msg
    @adapter.send id, @_packServerMessage(msg)

  _broadcast: (msg) ->
    @_logOutgoing msg.type, "(BROADCAST)", msg
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

  _log:(args...) ->
    console.log "=== Server:", args...

  _logDebug: (args...) ->
    @_log(args...) if @loggingConfig.debug

  _logIncoming: (args...) ->
    if @loggingConfig.incomingMessages and @loggingConfig.allowMessage(args...)
      console.log ">>> Server RECV:", args...

  _logOutgoing: (args...) ->
    if @loggingConfig.outgoingMessages and @loggingConfig.allowMessage(args...)
      console.log "<<< Server SEND:", args...



module.exports = Server
