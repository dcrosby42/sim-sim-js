
createSimulation = (opts={}) ->
  unless opts.adapter
      throw new Error("Cannot build simulation without network adapter config info")

  unless opts.world
      throw new Error("Cannot build simulation without an instane of 'world', which must implement interface WorldBase")

  adapter = createAdapter(opts.adapter)

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
    adapter
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

  if callback1 = opts.adapter.spyOnDataIn
    adapter.on 'ClientAdapter::Packet', (data) ->
      callback1(simulation, data)

  if callback2 = opts.adapter.spyOnDataOut
    adapter.on 'ClientAdapter::SendingData', (data) ->
      callback2(simulation, data)

  if opts.client
    if callback3 = opts.client.spyOnIncoming
      client.on 'incomingMessage', (msg) -> callback3(simulation, msg)

    if callback4 = opts.client.spyOnOutgoing
      client.on 'outgoingMessage', (msg) ->
        callback4(simulation, msg)

  return simulation


adapterConstructors = {}
addAdapterConstructor = (type, constructor) ->
  adapterConstructors[type] = constructor
getAdapterConstructor = (type) ->
  adapterConstructors[type]

createAdapter = (adapterOpts) ->
  if constructor = adapterConstructors[adapterOpts.type]
    constructor(adapterOpts.options)
  else
    throw new Error("No adapter constructor found for type '#{adapterOpts.type}'")

addAdapterConstructor 'socket_io', (opts) ->
  SocketIOClientAdapter = require './socket_io_client_adapter.coffee'
  new SocketIOClientAdapter(opts)


#######################################################################
#
# EXPORTS
#
#######################################################################

exports.createSimulation = createSimulation

exports.Util = { fixFloat: require('./fix_float.coffee') }

exports.WorldBase = require('./world_base.coffee')

exports.addAdapter = addAdapterConstructor
