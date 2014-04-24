EventEmitter = require './event_emitter.coffee'

class SocketIOClientAdapter extends EventEmitter
  constructor: (opts={}) ->
    @_debugOn = false
    @url = opts.url or throw new Error("SocketIOClientAdapter needs a 'url' argument")
    @connectionBuilder = opts.connectionBuilder or window.io or throw new Error("SocketIOClientAdapter requires a connectionBuilder (typically Socket.io's window.io object) but it wasn't provided explicitly, and window.io isn't set.  Help?")
    @_first = true

  connect: ->
    if @_first
      @_debug "connecting"
      @_first = false
      @socket = @connectionBuilder.connect(@url)
    else
      @_debug "REconnecting"
      @socket = @connectionBuilder.connect(null,{'force new connection':true})
      
    @socket.on 'connection', (data) =>
      @_debug "connection established"
      @emiy 'ClientAdapter::Connected'
    @socket.on 'data', (data) =>
      @_debug "got data", data
      @emit 'ClientAdapter::Packet', data
    @socket.on 'disconnect', =>
      @_debug "disconnected"
      @emit 'ClientAdapter::Disconnected'
      @socket = null
  
  send: (data) ->
    if @socket
      @_debug 'sending data', data
      @emit 'ClientAdapter::SendingData', data
      @socket.emit('data', data)
    else
      throw new Error("SocketIOClientAdapter#send called but there's NO @socket connection available!?")

  disconnect: ->
    if @socket
      @_debug "disconnecting"
      @socket.disconnect()
      @socket = null

  _debug: (args...) ->
    console.log "[SocketIOClientAdapter]", args if @_debugOn

module.exports = SocketIOClientAdapter
