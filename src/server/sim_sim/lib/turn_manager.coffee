EventEmitter = require('events').EventEmitter
Timer = require './timer'

class TurnManager extends EventEmitter
  constructor: (@period) ->
    @active = false
    @timer = new Timer(@period, ((dt,elapsed) =>
      if @active
        @emit 'turn_ended', @current, dt, elapsed
        @current += 1
    ))
    @current = 0

  start: ->
    @active = true
    @timer.start()

  stop: ->
    @active = false
    @timer.stop()

  reset: ->
    @current = 0

module.exports = TurnManager
