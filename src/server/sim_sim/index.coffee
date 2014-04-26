#
# var simultSim = require('./simult_sim')
# server = simultSim.create.socketIOServer(socketIO: socketIO)
#


# createServer() creates a new Server.
#
# adapter - implementation of ServerAdapter. (required, no default)
# period - turn length in millis. (default = 100)
# turnManager - (default is a new TurnManager)
# serverMessageFactory - (default is a new ServerMessageFactory)
createServer = (opts={}) ->
  TurnManager           = require './lib/turn_manager'
  ServerMessageFactory  = require './lib/server_message_factory'
  SyncManager           = require './lib/sync_manager'
  LoggingConfig         = require './lib/logging_config'
  Server                = require './lib/server'
  period = opts.period || 100
  adapter = opts.adapter || throw new Error("adapter required")
  turnManager = opts.turnManager || new TurnManager(period)
  serverMessageFactory = opts.serverMessageFactory || new ServerMessageFactory()
  syncManager = opts.syncManager || new SyncManager()
  loggingConfig = if opts.logging
                    new LoggingConfig(opts.logging)
                  else
                    new LoggingConfig({"off":true})

  server = new Server(adapter, turnManager, serverMessageFactory, syncManager, loggingConfig)
  server
  
createSocketIOServerAdapter = (socketIO) ->
  throw new Error("socketIO required") unless socketIO
  SocketIOServerAdapter = require './lib/socket_io_server_adapter'
  adapter = new SocketIOServerAdapter(socketIO)
  adapter

# Creates a Server instance by providing a new instance of SocketIOServerAdapter.
#
# period - turn length in millis. (default = 100)
# turnManager - (default is a new TurnManager)
# serverMessageFactory - (default is a new ServerMessageFactory)
#
createServerUsingSocketIO = (opts={}) ->
  opts.adapter = createSocketIOServerAdapter(opts.socketIO)
  createServer(opts)

#
# Export public data and variables:
#

exports.create =
  server: createServer
  socketIOServer: createServerUsingSocketIO

exports.clientAssets = "#{__dirname}/client"
