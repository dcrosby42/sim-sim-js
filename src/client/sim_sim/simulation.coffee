fixFloat = require('./fix_float.coffee')

class Simulation
  constructor: (
      @world
      @client
      @turnCalculator
      @simulationStateFactory
      @simulationStateSerializer
      @userEventSerializer
    ) ->
    @lastTurnTime = 0
    @currentTurnNumber = null
    @_debugOn = false

  worldState: ->
    @world

  clientId: ->
    @client.clientId

  quit: ->
    @client.disconnect()
    @simState = null

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
      @turnCalculator.stepUntilTurnTime @simState, @world, elapsedTurnTime

    @client.update (gameEvent) =>
      switch gameEvent.type
        when 'GameEvent::TurnComplete'
          @_debug "GameEvent::TurnComplete", new Date().getTime()
          @turnCalculator.advanceTurn @simState, @world
          @lastTurnTime = timeInSeconds
          if gameEvent.turnNumber != @currentTurnNumber
            console.log "Simulation: turn number should be #{@currentTurnNumber} BUT WAS #{gameEvent.turnNumber}", gameEvent
          @currentTurnNumber = gameEvent.turnNumber + 1
          for simEvent in gameEvent.events
            switch simEvent.type

              when 'SimulationEvent::Event'
                userEvent = @userEventSerializer.unpack(simEvent.data)
                if userEvent.type == 'UserEvent::WorldProxyEvent'
                  if @world[userEvent.method]
                    @world[userEvent.method](simEvent.playerId, userEvent.args...)
                  else
                    throw new Error("WorldProxyEvent with method #{userEvent.method} CANNOT BE APPLIED because the world object doesn't have that method!")
                else
                  @world.incomingEvent(simEvent.playerId, userEvent)

              when 'SimulationEvent::PlayerJoined'
                @world.playerJoined simEvent.playerId

              when 'SimulationEvent::PlayerLeft'
                @world.playerLeft simEvent.playerId

          gameEvent.checksumClosure @world.getChecksum()

        when 'GameEvent::StartGame'
          @ourId = gameEvent.ourId
          @currentTurnNumber = gameEvent.currentTurn
          @simState = @simulationStateSerializer.unpackSimulationState(gameEvent.simState)
          @world.setData(gameEvent.worldState)
          console.log "GameEvent::StartGame. ourId=#{@ourId} currentTurnNumber=#{@currentTurnNumber} simState=",@simState, "worldState=", gameEvent.worldState

        when 'GameEvent::GamestateRequest'
          @simState ||= @simulationStateFactory.createSimulationState()
          packedSimState = @simulationStateSerializer.packSimulationState(@simState)
          gameEvent.gamestateClosure(packedSimState,@world.getData())

        when 'GameEvent::Disconnected'
          @simState = null
          # TODO: notify users of the simulation that we've been disconnected

  _debug: (args...) ->
    console.log "[Simulation]", args if @_debugOn

module.exports = Simulation
