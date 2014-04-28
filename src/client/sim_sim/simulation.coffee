fixFloat = require('./fix_float.coffee')

class Simulation
  _reset: ->
    @lastTurnTime = 0
    @currentTurnNumber = null
    @simState = null

  constructor: (
      @_world
      @client
      @turnCalculator
      @simulationStateFactory
      @simulationStateSerializer
      @userEventSerializer
    ) ->
    @_debugOn = false
    @_reset()

  start: ->
    @_reset()
    @client.connect()

  stop: ->
    @client.disconnect =>
      @_beDisconnected()


  clientId: ->
    @client.clientId

  getWorldIntrospector: ->
    @_world.getIntrospector()

  worldProxy: (method, args...) ->
    @sendEvent
      type: 'UserEvent::WorldProxyEvent'
      method: method
      args: args

  sendEvent: (event) ->
    @_debug "sendEvent", event
    @client.sendEvent @userEventSerializer.pack(event)

  # Accepts overall elapsed time in floating point seconds
  update: (timeInSeconds) ->
    if @simState
      elapsedTurnTime = fixFloat(timeInSeconds - @lastTurnTime)
      @turnCalculator.stepUntilTurnTime @simState, @_world, elapsedTurnTime

    @client.update (gameEvent) =>
      switch gameEvent.type
        when 'GameEvent::TurnComplete'
          @_debug "GameEvent::TurnComplete", new Date().getTime()
          @turnCalculator.advanceTurn @simState, @_world
          @lastTurnTime = timeInSeconds
          if gameEvent.turnNumber != @currentTurnNumber
            console.log "Simulation: turn number should be #{@currentTurnNumber} BUT WAS #{gameEvent.turnNumber}", gameEvent
          @currentTurnNumber = gameEvent.turnNumber + 1
          for simEvent in gameEvent.events
            switch simEvent.type

              when 'SimulationEvent::Event'
                userEvent = @userEventSerializer.unpack(simEvent.data)
                if userEvent.type == 'UserEvent::WorldProxyEvent'
                  if @_world[userEvent.method]
                    @_world[userEvent.method](simEvent.playerId, userEvent.args...)
                  else
                    throw new Error("WorldProxyEvent with method #{userEvent.method} CANNOT BE APPLIED because the world object doesn't have that method!")
                else
                  @_world.incomingEvent(simEvent.playerId, userEvent)

              when 'SimulationEvent::PlayerJoined'
                @_world.playerJoined simEvent.playerId

              when 'SimulationEvent::PlayerLeft'
                @_world.playerLeft simEvent.playerId

          gameEvent.checksumClosure @_world.getChecksum()

        when 'GameEvent::StartGame'
          @_debug 'GameEvent::StartGame', gameEvent
          @ourId = gameEvent.ourId
          @currentTurnNumber = gameEvent.currentTurn
          @simState = @simulationStateSerializer.unpackSimulationState(gameEvent.simState)
          @_world.setData(gameEvent.worldState)
          console.log "GameEvent::StartGame. ourId=#{@ourId} currentTurnNumber=#{@currentTurnNumber} simState=",@simState, "worldState=", gameEvent.worldState

        when 'GameEvent::GamestateRequest'
          @_debug 'GameEvent::GameStateRequest', gameEvent
          @simState ||= @simulationStateFactory.createSimulationState()
          packedSimState = @simulationStateSerializer.packSimulationState(@simState)
          gameEvent.gamestateClosure(packedSimState,@_world.getData())

        when 'GameEvent::Disconnected'
          @_debug 'GameEvent::Disconnected', gameEvent
          @_beDisconnected()

  _beDisconnected: ->
    @_reset()
    @_world.theEnd()

  _debug: (args...) ->
    console.log "[Simulation]", args if @_debugOn

module.exports = Simulation
