
createSimulation = (opts={}) ->
  unless opts.adapter
      throw new error("Cannot build simulation without network adapter, such as SocketIOClientAdapter")
  # unless opts.worldClass
  #     throw new Error("Cannot build simulation without worldClass, which must implement interface WorldBase")
  unless opts.world
      throw new Error("Cannot build simulation without an instane of 'world', which must implement interface WorldBase")
  GameEventFactory = require './game_event_factory.coffee'
  ClientMessageFactory = require './client_message_factory.coffee'
  SimulationEventFactory = require './simulation_event_factory.coffee'
  Client = require './client.coffee'
  TurnCalculator = require './turn_calculator.coffee'
  SimulationStateFactory = require './simulation_state_factory.coffee'
  SimulationStateSerializer = require './simulation_state_serializer.coffee'
  UserEventSerializer = require './user_event_serializer.coffee'
  Simulation = require './simulation.coffee'

  gameEventFactory = new GameEventFactory()
  clientMessageFactory = new ClientMessageFactory()
  simulationEventFactory = new SimulationEventFactory()
  client = new Client(
    opts.adapter
    gameEventFactory
    clientMessageFactory
    simulationEventFactory
  )

  turnCalculator = new TurnCalculator()
  userEventSerializer = new UserEventSerializer()
  
  simulationStateFactory = new SimulationStateFactory(
    timePerTurn: opts.timesPerTurn || 0.1
    stepsPerTurn: opts.stepsPerTurn || 6
    step: opts.step || 0
  )

  simulationStateSerializer = new SimulationStateSerializer(simulationStateFactory)

  simulation = new Simulation(
    opts.world
    client
    turnCalculator
    simulationStateFactory
    simulationStateSerializer
    userEventSerializer
  )

  if callback = opts.spyOnDataIn
    opts.adapter.on 'ClientAdapter::Packet', (data) ->
      callback(simulation, data)

  if callback = opts.spyOnDataOut
    opts.adapter.on 'ClientAdapter::SendingData', (data) ->
      callback(simulation, data)

  return simulation

createSocketIOClientAdapter = (socketIO) ->
  SocketIOClientAdapter = require './socket_io_client_adapter.coffee'
  new SocketIOClientAdapter(socketIO)

createSimulationUsingSocketIO = (opts={}) ->
  opts.adapter = createSocketIOClientAdapter(opts.socketIO)
  createSimulation opts

#######################################################################
#
# EXPORTS
#
#######################################################################

exports.create =
  socketIOSimulation: createSimulationUsingSocketIO

exports.Util = { fixFloat: require('./fix_float.coffee') }

exports.WorldBase = require('./world_base.coffee')
