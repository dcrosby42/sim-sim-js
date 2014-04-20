SimulationEventFactory = require '../../../client/simult_sim/simulation_event_factory'

describe 'SimulationEventFactory', ->
  it "exists", ->
    expect(SimulationEventFactory).toBeDefined()

  subject = null

  beforeEach ->
    subject = new SimulationEventFactory()
  
  it 'should create an Event event structure', ->
    msg = subject.event(5,'the data')
    expect(msg).toEqual
      type: 'SimulationEvent::Event'
      playerId: 5
      data: 'the data'

  it 'should create a PlayerJoined event structure', ->
    msg = subject.playerJoined(6)
    expect(msg).toEqual
      type: 'SimulationEvent::PlayerJoined'
      playerId: 6

  it 'should create a PlayerLeft event structure', ->
    msg = subject.playerLeft(7)
    expect(msg).toEqual
      type: 'SimulationEvent::PlayerLeft'
      playerId: 7
