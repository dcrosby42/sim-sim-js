EventEmitter = require('events').EventEmitter

class Timer extends EventEmitter
  constructor: (@period,f) ->
    @on('tick', f) if f
    @reset()

  reset: ->
    @lastTime = null
    @elapsed = 0

  start: ->
    @lastTime = @_getTime()
    @interval = setInterval (=>
      now = @_getTime()
      dt = now - @lastTime
      @elapsed += dt
      @emit 'tick', dt, @elapsed
      @lastTime = now
    ), @period

  stop: ->
    clearInterval @interval if @interval
    @interval = null

  _getTime: ->
    new Date().getTime()

module.exports = Timer
