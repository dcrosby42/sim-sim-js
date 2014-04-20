EventEmitter = require '../../../client/simult_sim/event_emitter'

describe 'EventEmitter', ->
  it "exists", ->
    expect(EventEmitter).toBeDefined()

  subject = null

  beforeEach ->
    subject = new EventEmitter()
  
  it "can emit an event to a subscriber", ->
    value = 'unset'
    subject.on 'hello', -> value = 'fired'
    subject.emit 'hello'
    expect(value).toEqual('fired')

  it "can emit args", ->
    value = 'unset'
    subject.on 'hello', (x,y)-> value = "fired #{x} #{y}"
    subject.emit 'hello', 42,37
    expect(value).toEqual('fired 42 37')

  it "bases firing/subcription on event name", ->
    helloValue = 'unset1'
    pingValue = 'unset2'
    subject.on 'hello', -> helloValue = "hello fired"
    subject.on 'ping', -> pingValue = "ping fired"

    subject.emit 'ping'
    expect(pingValue).toEqual('ping fired')
    expect(helloValue).toEqual('unset1')
    subject.emit 'hello'
    expect(helloValue).toEqual('hello fired')

  it 'does nothing if no subscribers', ->
    subject.emit 'whatever'

  it 'can fire to multiple subscribers', ->
    value1 = 'unset'
    value2 = 'unset'

    subject.on 'hello', (x,y)-> value1 = "fired1 #{x} #{y}"
    subject.on 'hello', (x,y)-> value2 = "fired2 #{x} #{y}"

    subject.emit 'hello', 42,37
    expect(value1).toEqual('fired1 42 37')
    expect(value2).toEqual('fired2 42 37')

    # AGAIN
    value1 = 'unset'
    value2 = 'unset'
    subject.emit 'hello', 101,202
    expect(value1).toEqual('fired1 101 202')
    expect(value2).toEqual('fired2 101 202')
  
    
  
