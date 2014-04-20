class EventEmitter
  on: (event,f) ->
    @_getListeners(event).push(f)

  emit: (event,args...) ->
    f(args...) for f in @_getListeners(event)
    null

  _getListeners: (event) ->
    @_listeners ||= {}
    @_listeners[event] ||= []
    @_listeners[event]

module.exports = EventEmitter
