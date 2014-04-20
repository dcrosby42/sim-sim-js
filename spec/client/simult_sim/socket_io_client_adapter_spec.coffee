SocketIOClientAdapter = require '../../../client/simult_sim/socket_io_client_adapter'
EventEmitter = require '../../../client/simult_sim/event_emitter'

describe 'SocketIOClientAdapter', ->
  it "exists", ->
    expect(SocketIOClientAdapter).toBeDefined()

  socket = null
  subject = null
  data = {some:"info"}

  # Configuration 
  beforeEach ->
    socket = new EventEmitter()
    socket.disconnect = ->
    subject = new SocketIOClientAdapter(socket)

  it "relays data events as ClientAdapter::Packet events", ->
    got = null
    subject.on 'ClientAdapter::Packet', (d) -> got = d
    socket.emit 'data', data
    expect(got).toEqual(data)

  it "sends messages through the socket as outbound data events", ->
    sent = null
    socket.on 'data', (d) -> sent = d
    subject.send(data)
    expect(sent).toEqual(data)
    
  it "disconnects the socket", ->
    spyOn(socket, 'disconnect')
    subject.disconnect()
    expect(socket.disconnect).toHaveBeenCalled()
  

