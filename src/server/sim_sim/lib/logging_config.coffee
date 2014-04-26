class LoggingConfig
  constructor: ({@debug, @incomingMessages, @outgoingMessages, @suppressTurnMessages, @filters,@off}) ->
    unless @off
      @filters ||= []
      @filters.push (args...) =>
        !(@suppressTurnMessages and args[0].match(/turn/i))

  addFilter: (filter) ->
    return if @off
    @filters.push(filter)

  allowMessage: (args...) ->
    return false if @off
    for f in @filters
      if !f(args...)
        return false
    return true


module.exports = LoggingConfig
