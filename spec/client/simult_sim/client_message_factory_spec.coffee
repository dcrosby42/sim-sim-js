ClientMessageFactory = require '../../../client/simult_sim/client_message_factory'

describe 'ClientMessageFactory', ->
  it "exists", ->
    expect(ClientMessageFactory).toBeDefined()

  subject = null

  beforeEach ->
    subject = new ClientMessageFactory()
  
  it 'should create a TurnFinished message structure', ->
    msg = subject.turnFinished("t1", "cs6")
    expect(msg).toEqual
      type: 'ClientMsg::TurnFinished'
      turnNumber: "t1"
      checksum: "cs6"

  it 'should create a Gamestate message structure', ->
    msg = subject.gamestate("player1", "the proto turn", "the game")
    expect(msg).toEqual
      type: 'ClientMsg::Gamestate'
      forPlayerId: 'player1'
      protoTurn: 'the proto turn'
      data: 'the game'

  it 'should create an Event message structure', ->
    msg = subject.event("daters")
    expect(msg).toEqual
      type: 'ClientMsg::Event'
      data: "daters"

    
  
