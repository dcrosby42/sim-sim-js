Simulation = require '../../../client/simult_sim/simulation'
GameEventFactory = require '../../../client/simult_sim/game_event_factory'
SimulationEventFactory = require '../../../client/simult_sim/simulation_event_factory'
UserEventSerializer = require '../../../client/simult_sim/user_event_serializer'

describe 'Simulation', ->
  subject = null

  client = null
  simulationStateFactory = null
  simulationStateSerializer = null
  turnCalculator = null
  t = 0
  defaultSimState = null
  serializedSimState = null
  
  gameEventFactory = new GameEventFactory()
  simulationEventFactory = new SimulationEventFactory()
  userEventSerializer = new UserEventSerializer()

  beforeEach ->
    client = {
      disconnect: ->
      sendEvent: ->

      _testGameEvents: []
      update: (callback) ->
        while e = @_testGameEvents.shift()
          callback(e)
    }
    turnCalculator = jasmine.createSpyObj 'turnCalculator', [
      'advanceTurn'
      'stepUntilTurnTime'
    ]
    simulationStateFactory = { createSimulationState: (->) }
    simulationStateSerializer = { packSimulationState: (->), unpackSimulationState: (->), calcWorldChecksum: (->) }
    subject = new Simulation(
      client
      turnCalculator
      simulationStateFactory
      simulationStateSerializer
      userEventSerializer
    )

    defaultSimState = { default_sim_state: 'just holding space' }
    serializedSimState = 'serialized sim state'


    t = 0
    
    @world =
      playerJoined: null
      playerLeft: null
      incomingEvent: (->)
      shootGun: null
  
  it 'exists', ->
    expect(Simulation).toBeDefined()
    
  describe 'worldState', ->
    it 'returns null if simState not yet initialized', ->
      expect(subject.worldState()).toEqual(null)

    # TODO: this test kinda sucks because it forces internal state.  Better than nothing for now.
    it 'returns the world from simState', ->
      subject.simState = defaultSimState
      subject.simState.world = "the world"
      expect(subject.worldState()).toEqual("the world")

  describe 'worldProxy', ->
    it 'creates a UserEvent::WorldProxyEvent and sends it', ->
      spyOn(client, "sendEvent")
      subject.worldProxy('goBananas', 42, "cats")
      event = {type: 'UserEvent::WorldProxyEvent', method: 'goBananas', args: [42,"cats"]}
      expect(client.sendEvent).toHaveBeenCalledWith(userEventSerializer.pack(event))
      
  describe 'sendEvent', ->
    it 'packs the given event and send it through @client', ->
      spyOn(client, "sendEvent")
      event = {type:'x', stuff:'data'}
      subject.sendEvent(event)
      expect(client.sendEvent).toHaveBeenCalledWith(userEventSerializer.pack(event))

  describe 'quit', ->
    it 'calls disconnect on the client', ->
      spyOn(client, "disconnect")
      subject.quit()
      expect(client.disconnect).toHaveBeenCalled()
      
  describe 'update', ->
    it 'steps the simState appropriate to the given time', ->
      subject.simState = defaultSimState # nauhgty

      subject.update(0.25)
      subject.update(0.5)

      expect(turnCalculator.stepUntilTurnTime).toHaveBeenCalledWith(subject.simState, 0.25)
      expect(turnCalculator.stepUntilTurnTime).toHaveBeenCalledWith(subject.simState, 0.5)

      # See the time sent to turnCalculator is relative to lastTurnTime
      subject.lastTurnTime = 1.5 # TODO damn naughty! not for us to say! (Better: use TurnCompleted event!)
      subject.update(1.8)
      expect(turnCalculator.stepUntilTurnTime).toHaveBeenCalledWith(subject.simState, 0.3)

      

    describe 'GameEvent::GamestateRequest', ->
      it 'generates a new SimulationState and invokes the gamestate callback w serialized sim state', ->
        # Prep the gamestate event and its callback:
        providedState = null
        reqEvent = gameEventFactory.gamestateRequest (gamestate) -> providedState = gamestate
        client._testGameEvents.push reqEvent

        # Get ready to create and serialize simState
        spyOn(simulationStateFactory, "createSimulationState").andReturn(defaultSimState)
        spyOn(simulationStateSerializer, "packSimulationState").andReturn(serializedSimState)

        expect(subject.simState).toEqual null  # naughty. peeking!

        # GO
        subject.update(t)

        # See internal simState ref is set now:
        expect(subject.simState).toEqual defaultSimState # naughty. peeking!
        # Double check the usage of the state serializer:
        expect(simulationStateSerializer.packSimulationState).toHaveBeenCalledWith(defaultSimState)
        # Make sure the proper data was sent to the gamestate callback:
        expect(providedState).toEqual serializedSimState

      it 'uses pre-existing simState if already set', ->
        existingSimState = {stand:"in"}
        subject.simState = existingSimState

        # Prep the gamestate event and its callback:
        providedState = null
        reqEvent = gameEventFactory.gamestateRequest (gamestate) -> providedState = gamestate
        client._testGameEvents.push reqEvent

        # Get ready to create and serialize simState
        spyOn(simulationStateFactory, "createSimulationState").andReturn(defaultSimState)
        spyOn(simulationStateSerializer, "packSimulationState").andReturn(serializedSimState)

        expect(subject.simState).toEqual existingSimState  # naughty. peeking!

        # GO
        subject.update(t)

        # See internal simState ref is set now:
        expect(subject.simState).toEqual existingSimState # naughty. peeking!
        # Double check the usage of the state serializer:
        expect(simulationStateSerializer.packSimulationState).toHaveBeenCalledWith(existingSimState)
        # Make sure the proper data was sent to the gamestate callback:
        expect(providedState).toEqual serializedSimState

    
    describe 'GameEvent::StartGame', ->
      it 'sets our player id and simulation state', ->
        newId = 'the new playerId'
        turnPeriod = 0.2 # unused?
        currentTurn = 154 # unused?
        gamestate = 'serialized incoming state'
        newSimState = { unpacked: "state" }

        startEvent = gameEventFactory.startGame newId, turnPeriod, currentTurn, gamestate
        client._testGameEvents.push startEvent

        spyOn(simulationStateSerializer, "unpackSimulationState").andReturn(newSimState)

        subject.update(t)

        expect(subject.ourId).toEqual newId #naughty. peeking!
        expect(subject.simState).toEqual newSimState # naughty. peeking!

        expect(simulationStateSerializer.unpackSimulationState).toHaveBeenCalledWith(gamestate)

    describe 'GameEvent::Disconnected', ->
      it "sets simState to null", ->
        client._testGameEvents.push gameEventFactory.disconnected()

        existingSimState = {stand:"in"}
        subject.simState = existingSimState

        subject.update(t)

        expect(subject.simState).toEqual null

  describe 'GameEvent::TurnComplete', ->
    turnComplete = null
    turnNumber = 54321
    turnCompleteEvents = null
    sentChecksum = null
    checksumClosure = (checksum) -> 
      sentChecksum = checksum

    beforeEach ->
      turnCompleteEvents = []
      turnComplete = gameEventFactory.turnComplete(turnNumber,turnCompleteEvents,checksumClosure)
      client._testGameEvents.push turnComplete

      subject.simState =
        world: @world
        
    
    it 'advances the current turn in simState', ->
      expect(subject.lastTurnTime).toEqual 0
      subject.update(0.4)
      expect(turnCalculator.advanceTurn).toHaveBeenCalledWith(subject.simState)
      expect(subject.lastTurnTime).toEqual 0.4

    it "creates a checksum over the state of the world", ->
      previousChecksum = 'the old world checksum'
      worldChecksum = 'the world checksum'
      subject.simState.checksum = previousChecksum
      spyOn(simulationStateSerializer, 'calcWorldChecksum').andReturn(worldChecksum)
      turnCompleteEvents.push simulationEventFactory.event(11, {type:'whatever',val:'whocares'})

      subject.update(t)

      expect(simulationStateSerializer.calcWorldChecksum).toHaveBeenCalledWith(@world,previousChecksum)
      expect(sentChecksum).toEqual worldChecksum
      expect(subject.simState.checksum).toEqual worldChecksum


    describe 'on SimulationEvent::Event', ->
      describe 'containing WorldProxyEvent', ->
        it "invokes the specified method on the world", ->
          userEvent = {type:'UserEvent::WorldProxyEvent', method: 'shootGun', args:["flare",4]}
          turnCompleteEvents.push simulationEventFactory.event(11, userEvent)
          spyOn(@world, 'shootGun')

          subject.update(t)
          expect(@world.shootGun).toHaveBeenCalledWith(11, "flare", 4)

      describe 'containing some other event', ->
        it "invokes incomingEvent the world", ->
          userEvent = {type:'UserEvent::SomethingElse', unspecified: {things:"inside"}}
          turnCompleteEvents.push simulationEventFactory.event(22, userEvent)

          spyOn(@world, 'incomingEvent')

          subject.update(t)
          expect(@world.incomingEvent).toHaveBeenCalledWith(22, userEvent)


    describe 'on SimulationEvent::PlayerJoined', ->
      it 'tells the world a player joined', ->
        turnCompleteEvents.push simulationEventFactory.playerJoined(37)
        spyOn(@world, 'playerJoined')
        subject.update(t)
        expect(@world.playerJoined).toHaveBeenCalledWith(37)

    describe 'on SimulationEvent::PlayerLeft', ->
      it 'tells the world a player left', ->
        turnCompleteEvents.push simulationEventFactory.playerLeft(42)
        spyOn(@world, 'playerLeft')
        subject.update(t)
        expect(@world.playerLeft).toHaveBeenCalledWith(42)
    
  

      
    
