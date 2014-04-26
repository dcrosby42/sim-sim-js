# sim-sim-js

A networking library for synchronous state maintenance in multiplayer HTML5 games.

It consists of:

1. Node.js server component that plays nice with Express, and eg, Socket.IO
2. In-browser component to write your games against.

![eg bumpercats](https://github.com/dcrosby42/bumpercats/raw/master/demo.gif)

## Install

    npm install sim-sim-js --save

## Wat 
sim-sim-js is a Javascript (Node.js + browser) port of Job Vranish's Simultanous Simulation demo at https://github.com/jvranish/simultaneous-simulation.

Simultaneous Simulation is a game state synchronization technique based on gauranteed lock-step simulation based on synchronized, ordered input event delivery.

Clients generate and control all state.  ALL interesting action happens in the client-side implementation of "the game world" (see WorldBase abstract base class).

The server is generic, and simply generates turn pacining and brokers event delivery and state sync messages between clients.


## Server code

    ...
    var simSim  = require('sim-sim-js');
    ...
    var simultSimServer = simSim.create.socketIOServer(
        socketIO: socketIO,
        period: 100
        logging:
          debug: true
          incomingMessages: true
          outgoingMessages: true
          suppressTurnMessages: true

console.log "SimSim logging config:\n",logging

simultSimServer = simSim.create.socketIOServer(
  socketIO: socketIO
  period: 100
  logging: logging
)
    );
    ...
    expressApp.use("/sim_sim", express.static(simSim.clientAssets));
    ...
    
## Client Code
Establish a connected Simulation using the built-in Socket.io adapter:

    var sim = SimSim.createSimulation(
        adapter: {
            type: 'socket_io',
            options: { url: "http://#{location.hostname}:#{location.port}" }
        },
        world: new MyGameWorld()
    );


## Online example

Play http://bumpercats.heroku.com  (source at https://github.com/dcrosby42/bumpercats)

Even earlier (unstable) examples running at http://simsimjs-demos.herokuapp.com/


> Written with [StackEdit](https://stackedit.io/).
