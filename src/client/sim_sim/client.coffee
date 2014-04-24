EventEmitter = require './event_emitter.coffee'

class Client extends EventEmitter
  _reset: ->
    @gameStarted = false
    @clientId = null
    @simulationEventsBuffer = []
    @gameEventsBuffer = []
    @preGameEventsBuffer = []

  constructor: (@adapter,@gameEventFactory, @clientMessageFactory, @simulationEventFactory) ->
    @_debugOn = false
    @_reset()

    @adapter.on 'ClientAdapter::Disconnected', =>
      @_debug "rec'd ClientAdapter::Disconnected"
      @gameEventsBuffer.push @gameEventFactory.disconnected()
      @_reset()

    @adapter.on 'ClientAdapter::Packet', (data) =>
      msg = @_unpackServerMessage(data)
      @_debug "rec'd ClientAdapter::Packet", msg unless msg.type == 'ServerMessage::TurnComplete'
      switch msg.type
        when 'ServerMessage::IdAssigned'
          @clientId = msg.ourId

        when 'ServerMessage::Event'
          @simulationEventsBuffer.push @simulationEventFactory.event(msg.sourcePlayerId, msg.data)

        when 'ServerMessage::PlayerJoined'
          @simulationEventsBuffer.push @simulationEventFactory.playerJoined(msg.playerId)

        when 'ServerMessage::PlayerLeft'
          @simulationEventsBuffer.push @simulationEventFactory.playerLeft(msg.playerId)

        when 'ServerMessage::TurnComplete'
          @_turnComplete msg

        when 'ServerMessage::StartGame'
          @gameStarted = true
          for simEvent in @_unpackProtoTurn(msg.protoTurn)
            @simulationEventsBuffer.push simEvent

          @preGameEventsBuffer.push @gameEventFactory.startGame(msg.yourId, msg.turnPeriod, msg.currentTurn, msg.simState, msg.worldState)

        when 'ServerMessage::GamestateRequest'
          copyOfSimEvents = @simulationEventsBuffer.slice(0)
          protoTurn = @_packProtoTurn(copyOfSimEvents)
          f = (simState,worldState) =>
            @_sendMessage @clientMessageFactory.gamestate(
              msg.forPlayerId
              protoTurn
              simState
              worldState
            )
          gameEvent = @gameEventFactory.gamestateRequest(f)
          if @gameStarted
            @gameEventsBuffer.push gameEvent
          else
            @preGameEventsBuffer.push gameEvent

  update: (callback) ->
    for i in [0...@preGameEventsBuffer.length]
      callback @preGameEventsBuffer.shift()
    if @gameStarted
      for i in [0...@gameEventsBuffer.length]
        event = @gameEventsBuffer.shift()
        callback(event)

  sendEvent: (data) ->
    @_sendMessage @clientMessageFactory.event(data)
  
  connect: ->
    @_debug "connect"
    @adapter.connect()
  
  disconnect: ->
    @_debug "disconnect"
    @adapter.disconnect()

  _turnComplete: (msg) ->
    turnEvents = []
    for i in [0...@simulationEventsBuffer.length]
      turnEvents.push @simulationEventsBuffer.shift()
     
    f = (checksum) =>
      @_sendMessage @clientMessageFactory.turnFinished(
        msg.turnNumber,
        checksum
      )
    @gameEventsBuffer.push @gameEventFactory.turnComplete(
      msg.turnNumber,
      turnEvents,
      f
    )


  _unpackServerMessage: (data) ->
    data

  _packClientMessage: (msg) ->
    msg

  _packProtoTurn: (events) ->
    events

  _unpackProtoTurn: (protoTurn) ->
    protoTurn

  _sendMessage: (msg) ->
    @_debug "_sendMessage", msg unless msg.type == 'ClientMsg::TurnFinished'
    @adapter.send @_packClientMessage(msg)

  _debug: (args...) ->
    console.log "[Client]", args... if @_debugOn


module.exports = Client
