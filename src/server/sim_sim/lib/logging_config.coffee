class LoggingConfig
  constructor: ({@debug, @incomingMessages, @outgoingMessages, @suppressTurnMessages, @filters}) ->
    @filters ||= []
    @filters.push (args...) =>
      !(@suppressTurnMessages and args[0].match(/turn/i))

  addFilter: (filter) ->
    @filters.push(filter)

  allowMessage: (args...) ->
    for f in @filters
      if !f(args...)
        return false
    return true

  # allowMessageType: (type,args...) ->
  #   if @suppressTurnMessages and type.match(/turn/i)
  #     false
  #   else
  #     true

module.exports = LoggingConfig
