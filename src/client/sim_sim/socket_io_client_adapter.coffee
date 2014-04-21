EventEmitter = require './event_emitter.coffee'

class SocketIOClientAdapter extends EventEmitter
  constructor: (opts={}) ->
    @socket = opts.socket or opts.io
    url = opts.url
    if url and !@socket
      socketIO = window.io or throw new Error("Trying to construct SocketIOClientAdapter with URL '#{url}' but cannot find loaded socket.io library via window.io?")
      @socket = socketIO.connect(url)

    throw new Error("SockedIOClientAdapter: provide 'socket' or 'url' named arguments") unless @socket
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
