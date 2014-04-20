GameEventFactory = require '../../../client/simult_sim/game_event_factory'

describe 'GameEventFactory', ->
  it "exists", ->
    expect(GameEventFactory).toBeDefined()

  subject = null

  beforeEach ->
    subject = new GameEventFactory()
  
  it 'should create a Disconnected event structure', ->
    msg = subject.disconnected()
    expect(msg).toEqual
      type: 'GameEvent::Disconnected'
  
  it 'should create a GamestateRequest event structure', ->
    invoked = false
    msg = subject.gamestateRequest ->
      invoked = true
    expect(msg.type).toEqual 'GameEvent::GamestateRequest'
    expect(invoked).toBe false
    msg.gamestateClosure()
    expect(invoked).toBe true
  
  it 'should create a StartGame event structure', ->
    msg = subject.startGame('the id', 'turn len', 't2', 'the game')
    expect(msg).toEqual
      type: 'GameEvent::StartGame'
      ourId: 'the id'
      turnPeriod: 'turn len'
      currentTurn: 't2'
      gamestate: 'the game'
  
  it 'should create a TurnComplete event structure', ->
    checksumCallback = false
    checksumClosure = -> checksumCallback = true
    msg = subject.turnComplete('t3', 'turn events', checksumClosure)
    expect(msg.type).toEqual 'GameEvent::TurnComplete'
    expect(msg.turnNumber).toEqual 't3'
    expect(msg.events).toEqual 'turn events'
    expect(checksumCallback).toBe false
    msg.checksumClosure()
    expect(checksumCallback).toBe true
