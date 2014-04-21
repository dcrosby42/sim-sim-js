EventEmitter = require './event_emitter.coffee'

class SocketIOClientAdapter extends EventEmitter
  constructor: (@socket) ->
    throw new Error("A socket.io socket instance is required to build SockedIOClientAdapter") unless @socket
    @socket.on 'data', (data) =>
      @emit 'ClientAdapter::Packet', data
    @socket.on 'disconnect', =>
      @emit 'ClientAdapter::Disconnected'
  
  send: (data) ->
    @emit 'ClientAdapter::SendingData', data
    @socket.emit('data', data)

  disconnect: ->
    @socket.disconnect()

module.exports = SocketIOClientAdapter
