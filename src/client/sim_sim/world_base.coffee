class WorldBase
  getData: ->
    throw new Error("Please implement WorldBase#getData")
  setData: (data) ->
    throw new Error("Please implement WorldBase#setData")
  getChecksum: ->
    throw new Error("Please implement WorldBase#getChecksum")
  playerJoined: (id) ->
    throw new Error("Please implement WorldBase#playerJoined")
  playerLeft: (id) ->
    throw new Error("Please implement WorldBase#playerLeft")
  incomingEvent: (id) ->
    throw new Error("Please implement WorldBase#incomingEvent")
  step: (dt) ->
    throw new Error("Please implement WorldBase#step")
  theEnd: ->
    console.log "SimSim WorldBase: theEnd.  Override this method in your World class to silence this message and handle this event."
    


module.exports = WorldBase
