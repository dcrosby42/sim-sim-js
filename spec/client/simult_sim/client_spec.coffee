Client = require '../../../client/simult_sim/client'
GameEventFactory = require '../../../client/simult_sim/game_event_factory'
ClientMessageFactory = require '../../../client/simult_sim/client_message_factory'
SimulationEventFactory = require '../../../client/simult_sim/simulation_event_factory'
EventEmitter = require '../../../client/simult_sim/event_emitter'

describe 'Client', ->
  adapter = null
  gameEventFactory = null
  clientMessageFactory = null
  simulationEventFactory = null
  subject = null
  gameEvents = null
  updateBlock = null

  # Helpers:

  packClientMessage = (msg) -> msg  # noop for now, but someday...

  packServerMessage = (msg) -> msg  # noop for now

  packProtoTurn = (simEventArray) -> simEventArray # noop for now
  unpackProtoTurn = (packedProtoTurn) -> packedProtoTurn # noop for now

  buildAndPackServerMessage = (name,info) ->
    info.type = "ServerMessage::#{name}"
    packServerMessage info

  emitPacket = (packet) ->
    adapter.emit 'ClientAdapter::Packet', packet

  emitServerMessagePacket = (name,info) ->
    packet = buildAndPackServerMessage name, info
    emitPacket packet
      
  beforeEach ->
    # Create a stubbed ClientAdapter for spying on:
    adapter = new EventEmitter()
    adapter.disconnect = ->
    adapter.send = (data) ->
    # Utilize the actual msg builders for clarity
    gameEventFactory = new GameEventFactory()
    clientMessageFactory = new ClientMessageFactory()
    simulationEventFactory = new SimulationEventFactory()

    subject = new Client(adapter, gameEventFactory, clientMessageFactory, simulationEventFactory)

    # Generic callback to pass to subject.update()
    gameEvents = []
    updateBlock = (event) ->
      gameEvents.push event

  describe 'when ClientAdapter::Disconnected arrives', ->
    describe 'before game is started', ->
      it 'enqueus it internally but does not relay', ->
        adapter.emit 'ClientAdapter::Disconnected'
        subject.update updateBlock
        expect(gameEvents.length).toEqual 0
        # once game is started, the disconnect event can come out:
        subject.gameStarted = true
        subject.update updateBlock
        e = gameEvents.shift()
        expect(e.type).toEqual("GameEvent::Disconnected")
      
    describe 'after game is started', ->
      beforeEach ->
        subject.gameStarted = true
      
      it 'enqueues a Disconnected message on ClientAdapter::Disconnected', ->
        adapter.emit 'ClientAdapter::Disconnected'
        subject.update updateBlock
        e = gameEvents.shift()
        expect(e.type).toEqual("GameEvent::Disconnected")
      
  describe 'when ClientAdapter::Packet arrives', ->

    describe 'with ServerMessage::IdAssigned', ->
      it 'sets clientId', ->
        emitServerMessagePacket 'IdAssigned', ourId: 'the new id'
        expect(subject.clientId).toEqual 'the new id'

    describe 'with ServerMessage::Event', ->
      it 'buffers a simulation event w data', ->
        emitServerMessagePacket 'Event', sourcePlayerId: 'p1', data: 'event1 data'
        emitServerMessagePacket 'Event', sourcePlayerId: 'p2', data: 'event2 data'
        expect(subject.simulationEventsBuffer).toEqual(
          [
            simulationEventFactory.event('p1', 'event1 data')
            simulationEventFactory.event('p2', 'event2 data')
          ]
        )
    describe 'with ServerMessage::PlayerJoined', ->
      it "buffers a simulation event for player joined", ->
        emitServerMessagePacket 'PlayerJoined', playerId: 'p1'
        emitServerMessagePacket 'PlayerJoined', playerId: 'p2'
        expect(subject.simulationEventsBuffer).toEqual(
          [
            simulationEventFactory.playerJoined('p1')
            simulationEventFactory.playerJoined('p2')
          ]
        )
    describe 'with ServerMessage::PlayerLeft', ->
      it "buffers a simulation event for player left", ->
        emitServerMessagePacket 'PlayerLeft', playerId: 'p1'
        emitServerMessagePacket 'PlayerLeft', playerId: 'p2'
        expect(subject.simulationEventsBuffer).toEqual(
          [
            simulationEventFactory.playerLeft('p1')
            simulationEventFactory.playerLeft('p2')
          ]
        )

    describe 'with ServerMessage::TurnComplete', ->
      it "bundles prior sim events into a turnComplete game event", ->
        emitServerMessagePacket 'Event', sourcePlayerId: 'p1', data: 'event1 data'
        emitServerMessagePacket 'PlayerJoined', playerId: 'p2'
        emitServerMessagePacket 'PlayerLeft', playerId: 'p3'
        emitServerMessagePacket 'Event', sourcePlayerId: 'p4', data: 'another data'

        subject.update updateBlock
        expect(gameEvents.length).toEqual 0

        emitServerMessagePacket 'TurnComplete', turnNumber: 37
        
        subject.update updateBlock
        # STILL should be nothing because @gameStarted not set true yet
        expect(gameEvents.length).toEqual 0

        subject.gameStarted = true

        # Go for real!
        subject.update updateBlock
        expect(gameEvents.length).toEqual 1

        event = gameEvents.shift()
        expect(event.type).toEqual 'GameEvent::TurnComplete'
        expect(event.events).toEqual [
          simulationEventFactory.event 'p1', 'event1 data'
          simulationEventFactory.playerJoined 'p2'
          simulationEventFactory.playerLeft 'p3'
          simulationEventFactory.event 'p4', 'another data'
        ]
        expect(event.checksumClosure).toBeDefined()

        # The TurnComplete game event contains a followup function
        # that packs and sends ClientMsg::TurnFinished back to the server.
        spyOn(adapter, "send")
        expectedMsg = clientMessageFactory.turnFinished(37, 'le checksum')
        packedMsg = packClientMessage(expectedMsg)

        # Run the closure:
        event.checksumClosure('le checksum')

        expect(adapter.send).toHaveBeenCalledWith(packedMsg)

    describe 'with ServerMessage::StartGame', ->
      simEvents = []
      yourId = 42
      turnPeriod = 0.25
      currentTurn = 23
      gamestate = 'serialized game state'

      beforeEach ->
        simEvents = [
          simulationEventFactory.event 'p1', 'event1 data'
          simulationEventFactory.playerJoined 'p2'
        ]
      
      emitStartGame = ->
        emitServerMessagePacket 'StartGame',
          yourId: yourId
          turnPeriod: turnPeriod
          currentTurn: currentTurn
          protoTurn: packProtoTurn(simEvents)
          gamestate: gamestate

      # Naughty.  Peeking!
      it "sets gameStarted to true", ->
        expect(subject.gameStarted).toBeFalsy()
        emitStartGame()
        expect(subject.gameStarted).toBeTruthy()

      # Naughty.  Peeking!
      it "populates the sim events w contents of protoTurn", ->
        expect(subject.simulationEventsBuffer.length).toEqual 0
        emitStartGame()
        expect(subject.simulationEventsBuffer).toEqual simEvents

      it "enqueues a StartGame event for next update", ->
        emitStartGame()
        expect(gameEvents).toEqual []

        subject.update updateBlock

        expect(gameEvents.length).toEqual 1
        expect(gameEvents.shift()).toEqual gameEventFactory.startGame(
          yourId,
          turnPeriod,
          currentTurn,
          gamestate)

    describe 'with ServerMessage::GamestateRequest', ->
      gamestate = 'serialized gamestate'
      requestingPlayerId = 99

      beforeEach ->
        spyOn(adapter, "send")
        
      
      testGamestateRequest = ->
        # generate some simulation events
        emitServerMessagePacket 'Event', sourcePlayerId: 'p1', data: 'event1 data'
        emitServerMessagePacket 'Event', sourcePlayerId: 'p2', data: 'event2 daters'
        # initiate the state request
        emitServerMessagePacket 'GamestateRequest', forPlayerId: requestingPlayerId
        # Regression test: make sure that events arriving AFTER GamestateRequest DON'T add to proto turn:
        #  (this is how it goes down in real life for the first player)
        emitServerMessagePacket 'PlayerJoined', playerId: 'p2'

        # GO!
        subject.update updateBlock

        # At this point, the 'ask' for gamestate has been emitted from the Client:
        event = gameEvents.shift()
        expect(event.gamestateClosure).toBeDefined()

        expect(adapter.send).not.toHaveBeenCalled()

        # Invoke the callback to provide gamestate:
        event.gamestateClosure(gamestate)

        expect(adapter.send).toHaveBeenCalledWith clientMessageFactory.gamestate(
          requestingPlayerId,
          packProtoTurn([
            simulationEventFactory.event 'p1', 'event1 data'
            simulationEventFactory.event 'p2', 'event2 daters'
          ]),
          gamestate)

      it 'packs up a protoTurn based on current sim events, then asks the user code for serialized gamestate, then sends a Gamestate msg to the server', ->
        subject.gameStarted = true  # naughty. cheats.  do this more integration style? use real event?
        testGamestateRequest()
      it 'works similarly even if game not yet started', ->
        subject.gameStarted = false  # naughty. cheats.  
        testGamestateRequest()

  describe 'sendEvent', ->
    it "wraps the data in a ClientMsg::Event and sends over adapter", ->
      spyOn(adapter, "send")
      subject.sendEvent('the data')
      expect(adapter.send).toHaveBeenCalledWith clientMessageFactory.event('the data')

  describe 'disconnect', ->
    it "calls disconnect on the ClientAdapter", ->
      spyOn(adapter, "disconnect")
      subject.disconnect()
      expect(adapter.disconnect).toHaveBeenCalled()
      
      
      

